use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Write};

const BLOCK_SIZE: usize = 32;

fn reg_to_bin(reg: &str) -> Option<String> {
    reg.trim_start_matches('r')
        .parse::<u8>()
        .ok()
        .and_then(|n| {
            if n < 8 {
                Some(format!("{:03b}", n))
            } else {
                eprintln!("Register index r{} exceeds 3-bit width", n);
                None
            }
        })
}

fn assemble_line(
    line: &str,
    opcode_map: &HashMap<&str, &str>,
    label_to_block: &HashMap<String, usize>
) -> Option<String> {
    let tokens: Vec<&str> = line.split_whitespace().collect();
    if tokens.is_empty() {
        return None;
    }

    if tokens.len() == 1 && tokens[0].to_lowercase() == "nop" {
        return Some("000000000".to_string());
    }

    let opcode = opcode_map.get(tokens[0])?;

    if tokens[0] == "done" {
        return Some("111000000".to_string());
    }

    if tokens[0] == "br" {
        if tokens.len() != 3 {
            return None;
        }
        let rs = reg_to_bin(tokens[1])?;
        let label = tokens[2];
        let block_index = *label_to_block.get(label)?; // label must exist
        let block_bin = format!("{:03b}", block_index & 0x7);
        return Some(format!("{:09b}", u16::from_str_radix(&format!("{}{}{}", opcode, rs, block_bin), 2).unwrap()));
    }

    if tokens.len() != 3 {
        return None;
    }

    let rs = reg_to_bin(tokens[1])?;
    let rd = reg_to_bin(tokens[2])?;
    Some(format!("{}{}{}", opcode, rs, rd))
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input.asm> <output.bin>", args[0]);
        return;
    }

    let opcode_map: HashMap<&str, &str> = HashMap::from([
        ("sub", "000"),
        ("xor", "001"),
        ("shl", "010"),
        ("shr", "011"),
        ("add", "100"),
        ("lw",  "101"),
        ("sw",  "110"),
        ("br",  "111"),
        ("done", "111"),
    ]);

    let input = File::open(&args[1]).expect("Failed to open input file");
    let reader = BufReader::new(input);

    let mut raw_lines = Vec::new();
    for line in reader.lines() {
        let line = line.unwrap();
        let no_comment = line.split("//").next().unwrap().trim();
        if !no_comment.is_empty() {
            raw_lines.push(no_comment.to_string());
        }
    }

    let mut label_to_block = HashMap::new();
    let mut instr_lines = Vec::new();
    let mut pc = 0;

    for line in &raw_lines {
        if line.trim() == "exp_error0:" {
            // Pad with NOPs until PC = 256
            while pc < 256 {
                instr_lines.push("nop".to_string());
                pc += 1;
            }
        }

        if line.trim() == "exp_error1:" {
            // Pad with NOPs until PC = 288
            while pc < 288 {
                instr_lines.push("nop".to_string());
                pc += 1;
            }
        }

    if line.ends_with(":") {
        let label = line.trim_end_matches(":").to_string();
        if label == "exp_error0" {
            label_to_block.insert(label.clone(), 256 / BLOCK_SIZE);
        } else if label == "exp_error1" {
            label_to_block.insert(label.clone(), 288 / BLOCK_SIZE);
        } else {
            // Align to start of next 32-byte block
            let block_start = ((pc + BLOCK_SIZE - 1) / BLOCK_SIZE) * BLOCK_SIZE;
            while pc < block_start {
                instr_lines.push("nop".to_string());
                pc += 1;
            }
            label_to_block.insert(label.clone(), pc / BLOCK_SIZE);
        }
    } else {
        instr_lines.push(line.clone());
        pc += 1;
}

    }

    let mut output = File::create(&args[2]).expect("Failed to create output file");
    for line in &instr_lines {
        if let Some(binary) = assemble_line(line, &opcode_map, &label_to_block) {
            writeln!(output, "{}", binary).expect("Failed to write line");
        } else {
            eprintln!("Skipping invalid or malformed line: {}", line);
        }
    }

    println!("Assembled program written to {}", &args[2]);
}
