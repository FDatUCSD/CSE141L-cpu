import Defs::*;

module Control(
	input init,
	input [8:0] instruction,
	output ControlSignals ctrl
);

	opcode_t op;

	always_comb begin
		op = opcode_t'(instruction[8:6]);

		if (init) begin
			ctrl = '{default: 0, OP: op};

		end else if (instruction == 9'b001111000) begin
			// Special instruction: increment page
			ctrl = '{
				regWrite: 0, memRead: 0, memWrite: 0, branch: 0,
				MemToReg: 0, OP: op,
				incrementPage: 1, decrementPage: 0
			};

		end else if (instruction == 9'b001110000) begin
			// Special instruction: decrement page
			ctrl = '{
				regWrite: 0, memRead: 0, memWrite: 0, branch: 0,
				MemToReg: 0, OP: op,
				incrementPage: 0, decrementPage: 1
			};

		end else begin
			case (op)
				AND_OP, XOR_OP, SHL_OP, SHR_OP, ADD_OP: ctrl = '{
					regWrite: 1, memRead: 0, memWrite: 0, branch: 0,
					MemToReg: 0, OP: op,
					incrementPage: 0, decrementPage: 0
				};
				LW_OP: ctrl = '{
					regWrite: 1, memRead: 1, memWrite: 0, branch: 0,
					MemToReg: 1, OP: op,
					incrementPage: 0, decrementPage: 0
				};
				SW_OP: ctrl = '{
					regWrite: 0, memRead: 0, memWrite: 1, branch: 0,
					MemToReg: 0, OP: op,
					incrementPage: 0, decrementPage: 0
				};
				BR_OP: ctrl = '{
					regWrite: 0, memRead: 0, memWrite: 0, branch: 1,
					MemToReg: 0, OP: op,
					incrementPage: 0, decrementPage: 0
				};
				default: ctrl = '{default: 0, OP: op};
			endcase
		end
	end

endmodule
