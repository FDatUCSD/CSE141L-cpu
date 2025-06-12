`timescale 1ns / 1ps
module tb_CPU;

  logic clk;
  logic reset;

  CPU dut (
    .clk(clk),
    .reset(reset)
  );

  always #5 clk = ~clk;


  initial begin
    clk = 0;
    reset = 1;

    // Wait for 2 cycles to stabilize before preload
    repeat (2) @(posedge clk);

    // Preload memory while reset is high

    // Deassert reset
    reset = 0;

    @(posedge clk);
    
    dut.dataMem.memory[0] = 8'd2;
    dut.regFile.registers_arr[1] = 8'd3;

    // Wait 1 cycle before starting monitor
  end

    // Periodic monitoring block (every 10ns)
  always @(posedge clk) begin
    // Print a few example registers and memory locations
    $display("[Time %0t] PC = %0d | RF[1] = %0d | RF[2] = %0d | MEM[0] = %0d | MEM[1] = %0d | MEM[2] = %0d | ALURes = %0d | ALUOp = %d | ALUR1 = %d | ALUR2 = %d | ForwardA_out = %0d | ForwardA_sel = %0d | ForwardB_out = %0d | ForwardB_sel = %0d | Stall = %0d | RFWrite = %d | RFWrite_data = %d | DataMem_out = %d | IDEX_RDVal = %d | RFRdVal = %d | RFRsVal = %d", 
             $time,
             dut.fetch.PC,
             dut.regFile.registers_arr[1],
             dut.regFile.registers_arr[2],
             dut.dataMem.memory[0],
             dut.dataMem.memory[1],
             dut.dataMem.memory[2],
             dut.alu.OUT,
             dut.alu.OP,
             dut.alu.R1,
             dut.alu.R2,
             dut.forwardA.operandOut,
             dut.forwardA.forwardSel,
             dut.forwardB.operandOut,
             dut.forwardB.forwardSel,
             dut.hazardUnit.stall,
             dut.regFile.regWrite,
             dut.regFile.writeValue,
             dut.dataMem.readData,
             dut.idExReg.RdVal_in,
             dut.regFile.RdVal,
             dut.regFile.RsVal);
  end

  initial begin
    #400
    $display("===Done");

    // Dump files
    $dumpfile("cpu_dump.vcd");
    $dumpvars(0, tb_CPU);
    $finish;
  end
endmodule
