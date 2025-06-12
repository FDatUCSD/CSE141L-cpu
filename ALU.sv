module ALU(
	input logic [2:0] OP,
	input logic [7:0] R1,
	input logic [7:0] R2,
	output logic [7:0] OUT,
	output logic [1:0] OVERFLOW,
	output logic ZF);

	always_comb begin
		
		OVERFLOW = 0;
		ZF = 0;

		case(OP)

		3'b000: OUT = R1 & R2; // and r1 r2
		3'b001: OUT = R1 ^ R2; // xor r1 r2
		3'b010: OUT = {R2[6:0],R1[7]}; // shl r1 r2
		3'b011: OUT = R2 >> R1; // shr r1 r2

		3'b100: begin
			{OVERFLOW, OUT} = R2 + R1; // add r1 r2
			ZF = (OUT == 0); // set zero flag if add results in a 0
		end

		default: OUT = 8'b0;
		endcase
	end
endmodule