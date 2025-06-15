`timescale 1ns / 1ps
module tb_CPU_program;

  logic clk;
  logic reset;
  wire done;

  TopLevel dut (
    .clk(clk),
    .reset(reset),
    .done(done),
    .start(start)
  );

  always #5 clk = ~clk;

  // Define test vectors: {lo_byte, hi_byte, expected_float16}
  typedef struct {
    logic [7:0] lo, hi;
    logic [15:0] expected;
  } TestCase;

    TestCase tests[10] = '{
    '{8'h00, 8'h00, 16'h0000}, // +0.0
    '{8'h00, 8'h80, 16'h8000}, // -0.0
    '{8'h00, 8'h01, 16'h3C00}, // +1.0
    '{8'h00, 8'hFF, 16'h3BFF}, // +0.996 (just under 1.0)
    '{8'hFF, 8'hFF, 16'hBBFF}, // -0.00390625 (edge near zero)
    '{8'h01, 8'h3C, 16'h3C01}, // +1.00097656 (slightly above 1.0)
    '{8'h00, 8'hC0, 16'hC000}, // -2.0
    '{8'h00, 8'h7F, 16'h3800}, // +0.5
    '{8'h00, 8'hFF, 16'h3BFF}, // +0.996 (edge before overflow to 1.0)
    '{8'h00, 8'h20, 16'h3000}  // +0.125
    };


  integer i;
  logic [15:0] result;
  logic [15:0] expected_fp16;
  shortint input_val;
  bit sign;
  int abs_val;
  int shift, msb_pos;
  int norm;
  bit [4:0] exponent;
  bit [9:0] mantissa;

//   always @(posedge clk) begin
//     $display("[Time %0t] PC = %0d | RF[1] = %0d | MEM[0] = %0d | ALUOP = %b | ALURes = %0d | ALUR1 = %d | ALUR2 = %d | ForwardA_out = %0d | ForwardA_sel = %0d | ForwardB_out = %0d | ForwardB_sel = %0d | Stall = %0d | RFWrite = %d | RFWrite_data = %d | DataMemOut = %d | ForwardBranch_out = %d | ForwardBranch_sel = %d | ForwardBranch_fromMem = %d | Branching = %d", 
//              $time,
//              dut.fetch.PC,
//              dut.regFile.registers_arr[1],
//              dut.data_mem1.mem_core[0],
//              dut.alu.OP,
//              dut.alu.OUT,
//              dut.alu.R1,
//              dut.alu.R2,
//              dut.forwardA.operandOut,
//              dut.forwardA.forwardSel,
//              dut.forwardB.operandOut,
//              dut.forwardB.forwardSel,
//              dut.hazardUnit.stall,
//              dut.regFile.regWrite,
//              dut.regFile.writeValue,
//              dut.dataMem.readData,
//              dut.branchMux.operandOut,
//              dut.branchMux.forwardSel,
//              dut.branchMux.memVal,
//              dut.fetch.Branch);
//     end

  initial begin
    clk = 0;
    reset = 1;
    repeat (2) @(posedge clk);
    reset = 0;
    @(posedge clk);

    // Preload constants (identical for all tests)
    // dut.data_mem1.mem_core[4] = 8'hFF;
    // dut.data_mem1.mem_core[5] = 8'h01;
    // dut.data_mem1.mem_core[6] = 8'h0F;
    // dut.data_mem1.mem_core[7] = 8'h07;



    for (i = 0; i < $size(tests); i++) begin
      // Preload input number
      dut.data_mem1.mem_core[0] = tests[i].lo;
      dut.data_mem1.mem_core[1] = tests[i].hi;
      dut.data_mem1.mem_core[2] = 8'h00;
      dut.data_mem1.mem_core[3] = 8'h00;

      // Compute expected result in software
        // Combine hi and lo to form full 8.8 fixed-point input
        input_val = {tests[i].hi, tests[i].lo};

        if (input_val == 0) begin
        expected_fp16 = 16'h0000;
        end else begin
        // Extract sign and get absolute value
        sign = input_val[15];
        abs_val = sign ? -input_val : input_val;

        // Normalize to align MSB to bit 14 (position before sign)
        shift = 0;
        norm = abs_val;
        while ((norm & 16'h8000) == 0) begin
            norm <<= 1;
            shift++;
        end

        // Exponent calculation
        // We started with an 8.8 number. The binary point is 8 bits in.
        // So: exponent = bias (15) + original MSB pos (15) - shift - 8
        exponent = 15 + (15 - shift) - 8;

        // Shift normalized number to extract 10-bit mantissa
        // Top bit is the implicit 1, so shift out bit 15 and take the next 10
        mantissa = (norm << 1) >> 6;  // <<1 to skip implicit bit, >>6 = drop top 6 bits

        expected_fp16 = {sign, exponent[4:0], mantissa[9:0]};
        end


      tests[i].expected = expected_fp16;

      // Wait for done
      wait (done);
      @(posedge clk); // allow write to settle

      result = {dut.data_mem1.mem_core[3], dut.data_mem1.mem_core[2]};

      $display("Test %0d: input = %h%h, output = %h, expected = %h, %s",
               i, tests[i].hi, tests[i].lo, result, expected_fp16,
               (result == expected_fp16) ? "PASS" : "FAIL");

      if (result != expected_fp16)
        $error("Test %0d FAILED", i);

      // Reset for next test
      reset = 1;
      @(posedge clk);
      reset = 0;
    end

    $display("=== ALL TESTS DONE ===");
    $finish;
  end

endmodule
