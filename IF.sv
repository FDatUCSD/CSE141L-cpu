module IF_module(
  input Branch,
  input [2:0] Target,
  input Init,
  input Stall,
  input CLK,
  output logic[7:0] PC
  );

  logic signed [7:0] branch_offset;
	
	// Sign-extend the target bits and multiply by 4
	// We can only branch to a destination that is a multiple of 4
	assign branch_offset = {{5{Target[2]}}, Target} << 2;

  always @(posedge CLK)
	if(Init)
	  PC <= 0;
	else if(Stall)
	  PC <= PC;
	else if(Branch) begin
	  $display("Target = %b, branching to %b", Target, (PC + branch_offset));
		PC <= PC + branch_offset;
	end
	else
	  PC <= PC+1;

endmodule
