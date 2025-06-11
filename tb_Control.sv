`timescale 1ns/1ps

module tb_Control;

  // Inputs
  logic init;
  logic [8:0] instruction;

  // Outputs
  logic writeEnable;
  logic [2:0] OP;
  logic memRead;
  logic memWrite;
  logic branch;
  logic ALUSrc;
  logic MemToReg;

  // Instantiate the Control module
  Control dut (
    .init(init),
    .instruction(instruction),
    .writeEnable(writeEnable),
    .OP(OP),
    .memRead(memRead),
    .memWrite(memWrite),
    .branch(branch),
    .ALUSrc(ALUSrc),
    .MemToReg(MemToReg)
  );

  // Task to display results
  task print_control(string name);
    $display("[%s] instr[8:6]=%b | writeEnable=%b, OP=%b, memRead=%b, memWrite=%b, branch=%b, ALUSrc=%b, MemToReg=%b",
             name, instruction[8:6], writeEnable, OP, memRead, memWrite, branch, ALUSrc, MemToReg);
  endtask

  initial begin
    $display("=== Control Unit Test ===");

    init = 1;
    instruction = 9'b000_000_000;
    #1;
    print_control("INIT RESET");

    init = 0;

    // Test all opcodes
    instruction = 9'b000_000_000; #1; print_control("AND");
    instruction = 9'b001_000_000; #1; print_control("XOR");
    instruction = 9'b010_000_000; #1; print_control("SHL");
    instruction = 9'b011_000_000; #1; print_control("SHR");
    instruction = 9'b100_000_000; #1; print_control("ADD");
    instruction = 9'b101_000_000; #1; print_control("LW");
    instruction = 9'b110_000_000; #1; print_control("SW");
    instruction = 9'b111_000_000; #1; print_control("BRANCH");

    // Unknown opcode (should default)
    instruction = 9'bzzz_000_000; #1; print_control("DEFAULT (unknown)");

    $display("=== Test Complete ===");

  end

endmodule
