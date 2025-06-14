module ALU(
	input logic [2:0] OP,
	input logic [7:0] R1,
	input logic [7:0] R2,
	output logic [7:0] OUT,
	output logic [1:0] OVERFLOW,
	output logic ZF,
	output logic exp_error
	);

	always_comb begin

		OVERFLOW = 0;
		ZF = 0;

		case(OP)

		3'b000: OUT = R1 & R2; // and r1 r2
		3'b001: OUT = R1 ^ R2; // xor r1 r2
		3'b010: begin
			OUT = {R2[6:0],R1[7]}; // shl r1 r2
		end
		3'b011: begin
			OUT = {R1[0],R2[7:1]}; // shr r1 r2
		end

		3'b100: begin
			{OVERFLOW, OUT} = R2 + R1; // add r1 r2
			ZF = (OUT == 0); // set zero flag if add results in a 0
		end

		default: OUT = 8'b0;
		endcase

		if (R1 == 22 && OUT[7] == 1 && OP == 3'b100) begin
			$display("Exception: R1 is 22 and OUT is negative, setting exp_error");
			$display("R1: %d, R2: %d, OP: %b, OUT: %d", R1, R2, OP, OUT);
			exp_error = 1'b1; // Set exception error if R1 is 22 and OUT is negative
		end else begin
			exp_error = 1'b0; // Clear exception error otherwise
		end
		
	end
endmodule