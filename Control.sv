module Control(
	input init,
	input [8:0] instruction,
	output logic writeEnable, // write to RF, 0 = not writing to reg file, 1 = write to reg file
	output logic [2:0] OP, // ALU operation
	output logic memRead, // load from memory, 0 = not reading from memory, 1 = read from memory
	output logic memWrite, // store into memory, 0 = not writing to memory, 1 = writing to memory
	output logic branch, // 1 if branching
	output logic ALUSrc, // 0 = from register, 1 = immediate, only used for lw and sw
	output logic MemToReg // 0 = ALU result, 1 = memory result
	);

	typedef enum logic [2:0] {
		AND_OP  = 3'b000,
		XOR_OP  = 3'b001,
		SHL_OP  = 3'b010,
		SHR_OP  = 3'b011,
		ADD_OP  = 3'b100,
		LW_OP   = 3'b101,
		SW_OP   = 3'b110,
		BR_OP   = 3'b111
	} opcode_t;

	always_comb begin
		if(init) begin
			writeEnable = 0;
			OP = instruction[8:6];
			memRead = 0;
			memWrite = 0;
			branch = 0;
			ALUSrc = 0;
			MemToReg = 0;
		end else begin

			opcode_t decoded_op;
			decoded_op = opcode_t'(instruction[8:6]);
			OP = decoded_op;

			case(OP)
				AND_OP, XOR_OP, SHL_OP, SHR_OP, ADD_OP: begin // ALU op
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
					ALUSrc = 0;
					MemToReg = 0;
				end
				LW_OP: begin // lw
					writeEnable = 1;
					memRead = 1;
					memWrite = 0;
					branch = 0;
					ALUSrc = 1;
					MemToReg = 1;
				end
				SW_OP: begin // sw
					writeEnable = 0;
					memRead = 0;
					memWrite = 1;
					branch = 0;
					ALUSrc = 1;
					MemToReg = 0;
				end
				BR_OP: begin // branch
					writeEnable = 0;
					memRead = 0;
					memWrite = 0;
					branch = 1;
					ALUSrc = 0;
					MemToReg = 0;
				end

				default: begin
					writeEnable = 0;
					memRead = 0;
					memWrite = 0;
					branch = 0;
					ALUSrc = 0;
					MemToReg = 0;
				end

			endcase
		end
	end
endmodule