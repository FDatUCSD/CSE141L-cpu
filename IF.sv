module IF_module(
  input Branch,
  input [2:0] Target,
  input Init,
  input Stall,
  input done,
  input CLK,
  input logic [1:0] exp_error,
  input logic [2:0] base,
  output logic[9:0] PC
  );

  logic signed [9:0] branch_target;
	
	// Sign-extend the target bits and multiply by 4
	// We can only branch to a destination that is a multiple of 4
	assign branch_target = (256 * base) + Target << 5;

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
	else if (exp_error != 2'b00) begin
	  $display("Exception exp_error detected, branching PC at %d", PC);
	  case (exp_error)
	    2'b01: PC <= 256; // Return 0x7FFF
		2'b10: PC <= 288; // Return 0x8000
		default: PC <= PC; // No change for other cases
	  endcase
	end
	else if(Branch) begin
	//   $display("Target = %d", branch_target);
		PC <= branch_target;
	end
	else begin
		// $display("Incrementing PC: %d, %t", PC, $time);
	  PC <= PC+1;
	end

endmodule
