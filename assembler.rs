use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Write};

fn reg_to_bin(reg: &str) -> String {
    let reg_num: u8 = reg.trim_start_matches('r').parse().unwrap();
    format!("{:03b}", reg_num)
}

fn assemble_line(line: &str, opcode_map: &HashMap<&str, &str>) -> Option<String> {
    let tokens: Vec<&str> = line.split_whitespace().collect();
    if tokens.len() == 1 && tokens[0].to_lowercase() == "nop" {
        return Some("000000000".to_string());
    }

    if tokens.len() != 3 {
        return None;
    }

    let opcode = opcode_map.get(tokens[0])?;
    let rs = reg_to_bin(tokens[1]);
    let rd = reg_to_bin(tokens[2]);

    Some(format!("{}{}{}", opcode, rs, rd))
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        return;
    }

    let opcode_map: HashMap<&str, &str> = HashMap::from([
        ("and", "000"),
        ("xor", "001"),
        ("shl", "010"),
        ("shr",  "011"),
        ("add",  "100"),
        ("lw",  "101"),
        ("sw", "110"),
        ("br", "111"),
    ]);

    let input = File::open(&args[1]).expect("Failed to open input file");
    let reader = BufReader::new(input);

    let mut output = File::create(&args[2]).expect("Failed to create output file");

    for line in reader.lines() {
        let line = line.unwrap();
        if let Some(binary) = assemble_line(&line, &opcode_map) {
            writeln!(output, "{}", binary).expect("Failed to write");
        } else {
            eprintln!("Skipping invalid line: {}", line);
        }
    }

    println!("Assembled program written to {}", &args[2]);
}
