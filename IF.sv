module IF_module(
  input Branch,
  input [4:0] Target,
  input Init,
  input Halt,
  input CLK,
  output logic[7:0] PC
  );
	
  always @(posedge CLK)
	if(Init)
	  PC <= 0;
	else if(Halt)
	  PC <= PC;
	else if(Branch) begin
	  //$display("Target = %b", Target);
	  if(Target[4] == 1) begin
			//$display("Branching backwards %b lines!", (~{3'b111,Target} +  1'b1));
			PC <= PC - (~{3'b111,Target} +  1);
	  end
	  else begin
			//$display("Branching forwards %d lines!", Target);
			PC <= PC + Target;
	  end
	end
	else
	  PC <= PC+1;

endmodule
