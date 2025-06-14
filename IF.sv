module IF_module(
  input Branch,
  input [2:0] Target,
  input Init,
  input Stall,
  input done,
  input CLK,
  output logic[7:0] PC
  );

  logic signed [7:0] branch_target;
	
	// Sign-extend the target bits and multiply by 4
	// We can only branch to a destination that is a multiple of 4
	assign branch_target = Target << 4;

  always @(posedge CLK)
	if(Init) begin
	  $display("Resetting PC to 0");
	  PC <= 0;
	end
	else if(done) begin
	//   $display("Done, freezing PC, %t", $time);
	  PC <= PC;
	end
	else if(Stall)
	  PC <= PC;
	else if(Branch) begin
	//   $display("Target = %d", branch_target);
		PC <= branch_target;
	end
	else begin
		$display("Incrementing PC: %d, %t", PC, $time);
	  PC <= PC+1;
	end

endmodule
