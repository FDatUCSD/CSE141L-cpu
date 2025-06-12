`timescale 1ns/1ps

import Defs::*;  // Contains the typedef for ControlSignals

module tb_Control;

  // Inputs
  logic init;
  logic [8:0] instruction;

  // Output
  ControlSignals ctrl;

  // Instantiate the Control module
  Control dut (
    .init(init),
    .instruction(instruction),
    .ctrl(ctrl)
  );

  // Task to display results
  task print_control(string name);
    $display("[%s] instr[8:6]=%b | regWrite=%b, OP=%b, memRead=%b, memWrite=%b, branch=%b, MemToReg=%b",
             name, instruction[8:6], ctrl.regWrite, ctrl.OP, ctrl.memRead, ctrl.memWrite, ctrl.branch, ctrl.MemToReg);
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
