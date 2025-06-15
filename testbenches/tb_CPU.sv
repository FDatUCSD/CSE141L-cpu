`timescale 1ns / 1ps
module tb_CPU;

  logic clk;
  logic reset;
  wire done;
  wire start;

  TopLevel dut (
    .clk(clk),
    .reset(reset),
    .done(done),
    .start(start)
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
    
    // mem[0] = lo byte
    // mem[1] = hi byte;
    // mem[2] = lo byte return
    // mem[3] = hi byte return
    // mem[4] = 0xFF
    // mem[5] = 1
    // mem[6] = 0x0F (15)
    // mem[7] = 0x07
    // dut.data_mem1.mem_core[0] = 8'b00000000; // Load value 0 into memory[0]
    // dut.data_mem1.mem_core[1] = 8'h3c; // Load value 1 into memory[1]
    // dut.data_mem1.mem_core[2] = 8'b0;
    // dut.data_mem1.mem_core[3] = 8'b0;
    // dut.data_mem1.mem_core[4] = 8'hFF; // Load -1 into memory[4]
    // dut.data_mem1.mem_core[5] = 8'b00000001; // Load value 1 into memory[5]
    // dut.data_mem1.mem_core[6] = 8'h0F; // Load value 15 into memory[6]
    // dut.data_mem1.mem_core[7] = 8'h07; // Load value 7 into memory[7]
    // dut.regFile.registers_arr[1] = 8'b00000001; // Initialize register 0 to 0
    // dut.regFile.registers_arr[2] = 8'hFF; // Initialize register 1 to 0
    // populate register file 0-7 with values 1-8
    // for (int i = 0; i < 8; i++) begin
    //   dut.regFile.registers_arr[i] = i + 1; // Initialize registers 0-7 with values 1-8
    // end

    // Wait 1 cycle before starting monitor
  end

    // Periodic monitoring block (every 10ns)
  always @(posedge clk) begin
    // Print a few example registers and memory locations
    $display("  PC = %0d", dut.fetch.PC);
    $display(" [DataMem] Read Data: %0d", dut.data_mem1.memRead);
    // print instruction
    $display(" instruction = %b", dut.ifIdReg.instr_in);
    $display("[Time %0t] PC = %0d | RF[1] = %0d | MEM[0] = %0d | ALUOP = %b | ALURes = %0d | ALUR1 = %d | ALUR2 = %d | ForwardA_out = %0d | ForwardA_sel = %0d | ForwardB_out = %0d | ForwardB_sel = %0d | Stall = %0d | RFWrite = %d | RFWrite_data = %d | DataMemOut = %d | ForwardBranch_out = %d | ForwardBranch_sel = %d | ForwardBranch_fromMem = %d | Branching = %d", 
             $time,
             dut.fetch.PC,
             dut.regFile.registers_arr[1],
             dut.data_mem1.mem_core[0],
             dut.alu.OP,
             dut.alu.OUT,
             dut.alu.R1,
             dut.alu.R2,
             dut.forwardA.operandOut,
             dut.forwardA.forwardSel,
             dut.forwardB.operandOut,
             dut.forwardB.forwardSel,
             dut.hazardUnit.stall,
             dut.regFile.regWrite,
             dut.regFile.writeValue,
             dut.data_mem1.readData,
             dut.branchMux.operandOut,
             dut.branchMux.forwardSel,
             dut.branchMux.memVal,
             dut.fetch.Branch);

    // if (dut.fetch.PC == 8'd69) begin
    //   $display("[Time %0t] Reached PC 69, stopping simulation.", $time);
    //   $display("Your number is: %h or %b %b %b", {dut.data_mem1.mem_core[3], dut.data_mem1.mem_core[2]}, dut.dataMem.memory[3][7], dut.dataMem.memory[3][6:2], {dut.dataMem.memory[3][1:0], dut.dataMem.memory[2]});
    //   $stop;
    // end
    // $stop;

    // Check for done signal
    if (dut.done) begin
      $display("[Time %0t] CPU execution completed.", $time);
      // $display("Your number is: %h or %b %b %b", {dut.data_mem1.mem_core[3], dut.data_mem1.mem_core[2]}, dut.dataMem.memory[3][7], dut.dataMem.memory[3][6:2], {dut.dataMem.memory[3][1:0], dut.dataMem.memory[2]});
      $finish;
    end
    $stop;
  end

  initial begin
    #1000000
    $display("[Time %0t] Simulation timeout reached, terminating.", $time);

    // Dump files
    $dumpfile("cpu_dump.vcd");
    $dumpvars(0, tb_CPU);
    $finish;
  end
endmodule
