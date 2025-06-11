`timescale 1ns/1ps

module tb_IF_module;

  // Inputs
  logic CLK = 0;
  logic Init = 1;
  logic Halt = 0;
  logic Branch = 0;
  logic [2:0] Target = 3'b000;

  // Output
  logic [7:0] PC;

  // Instantiate the module under test
  IF_module uut (
    .Branch(Branch),
    .Target(Target),
    .Init(Init),
    .Halt(Halt),
    .CLK(CLK),
    .PC(PC)
  );

  // Clock generation
  always #5 CLK = ~CLK;

  // Stimulus
  initial begin
    $display("Time\tInit Halt Branch Target\tPC");

    // Initial reset
    #10 Init = 0;

    // Normal increments
    #10; #10;
    #10;

    // Branch forward (+4)
    Branch = 1;
    Target = 3'b001; // +4
    #10;
    Branch = 0;

    // Let it run
    #10; #10;

    // Branch backward (-4)
    Branch = 1;
    Target = 3'b111; // -1 * 4 = -4
    #10;
    Branch = 0;

    // Halt
    Halt = 1;
    #10;
    Halt = 0;

    // Let it increment once more
    #10;

    $finish;
  end

  // Monitor output after every rising edge
  always @(posedge CLK) begin
    #1 $display("%0t\t%b\t%b\t%b\t%b\t\t%b", $time, Init, Halt, Branch, Target, PC);
  end

endmodule
