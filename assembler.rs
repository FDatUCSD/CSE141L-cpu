use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Write};

fn reg_to_bin(reg: &str) -> String {
    let reg_num: u8 = reg.trim_start_matches('r').parse().unwrap();
    format!("{:03b}", reg_num)
}

fn assemble_line(
    line: &str,
    opcode_map: &HashMap<&str, &str>,
    pc: usize,
    offset_map: &HashMap<usize, isize>,
) -> Option<String> {
    let tokens: Vec<&str> = line.split_whitespace().collect();

    if tokens.len() == 1 && tokens[0].to_lowercase() == "nop" {
        return Some("000000000".to_string());
    }

    let opcode = opcode_map.get(tokens[0])?;

    if tokens[0] == "br" {
        if tokens.len() != 3 {
            return None;
        }

        let rs = reg_to_bin(tokens[1]);
        let imm = offset_map.get(&pc)?;
        let branch_imm = imm / 4;

        if branch_imm < -4 || branch_imm > 3 {
            eprintln!("Branch imm to '{}' out of range: {}", tokens[2], branch_imm);
            return None;
        }

        let imm_bin = format!("{:03b}", ((branch_imm + 8) % 8) as u8);
        return Some(format!("{}{}{}", opcode, rs, imm_bin));
    }

    if tokens.len() != 3 {
        return None;
    }

    let rs = reg_to_bin(tokens[1]);
    let rd = reg_to_bin(tokens[2]);
    Some(format!("{}{}{}", opcode, rs, rd))
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input.asm> <output.bin>", args[0]);
        return;
    }

    let opcode_map: HashMap<&str, &str> = HashMap::from([
        ("and", "000"),
        ("xor", "001"),
        ("shl", "010"),
        ("shr", "011"),
        ("add", "100"),
        ("lw",  "101"),
        ("sw",  "110"),
        ("br",  "111"),
    ]);

    let input = File::open(&args[1]).expect("Failed to open input file");
    let reader = BufReader::new(input);

    // Strip comments + whitespace
    let mut raw_lines = Vec::new();
    for line in reader.lines() {
        let line = line.unwrap();
        let no_comment = line.split("//").next().unwrap().trim();
        if !no_comment.is_empty() {
            raw_lines.push(no_comment.to_string());
        }
    }

    let mut label_to_index = HashMap::new();
    let mut branch_instrs: Vec<(usize, String)> = Vec::new();
    let mut instr_lines: Vec<String> = Vec::new();

    let mut pc = 0;
    for line in &raw_lines {
        if line.ends_with(":") {
            let label = line.trim_end_matches(":").to_string();
            label_to_index.insert(label, pc);
        } else {
            if line.starts_with("br") {
                let tokens: Vec<&str> = line.split_whitespace().collect();
                if tokens.len() == 3 {
                    branch_instrs.push((pc, tokens[2].to_string()));
                }
            }
            instr_lines.push(line.clone());
            pc += 1;
        }
    }

    // Insert NOPs based on branch-label distance misalignment
    let mut offset_map = HashMap::new();
    let mut i = 0;
    while i < instr_lines.len() {
        if let Some((_, label)) = branch_instrs.iter().find(|(idx, _)| *idx == i) {
            if let Some(&target_pc) = label_to_index.get(label) {
                let br_pc = i;
                let raw_offset = target_pc as isize - br_pc as isize - 1;
                let misalign = raw_offset % 4;
                let padding = if misalign != 0 { 4 - misalign } else { 0 };

                let final_offset = raw_offset + padding;
                offset_map.insert(br_pc, final_offset);

                if padding != 0 {
                    for _ in 0..padding {
                        instr_lines.insert(target_pc, "nop".to_string());
                    }

                    // Adjust label indices after nop insertion
                    for (_, v) in label_to_index.iter_mut() {
                        if *v > target_pc {
                            *v += padding as usize;
                        }
                    }

                    // Adjust future branch instruction positions
                    for (idx, _) in branch_instrs.iter_mut() {
                        if *idx > target_pc {
                            *idx += padding as usize;
                        }
                    }

                    i += padding as usize;
                }
            }
        }
        i += 1;
    }

    // Final offset map fallback for non-adjusted branches
    for (pc, label) in &branch_instrs {
        if !offset_map.contains_key(pc) {
            if let Some(&target_pc) = label_to_index.get(label) {
                let offset = target_pc as isize - *pc as isize - 1;
                offset_map.insert(*pc, offset);
            }
        }
    }

    // Final pass: assemble
    let mut output = File::create(&args[2]).expect("Failed to create output file");
    for (pc, line) in instr_lines.iter().enumerate() {
        if let Some(binary) = assemble_line(line, &opcode_map, pc, &offset_map) {
            writeln!(output, "{}", binary).expect("Failed to write");
        } else {
            eprintln!("Skipping invalid line: {}", line);
        }
    }

    println!("Assembled program written to {}", &args[2]);
}
