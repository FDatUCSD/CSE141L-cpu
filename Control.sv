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

            ctrl = '{default: 0};
            ctrl.OP = op;

        end else begin

            ctrl.OP = op;
            case (op)
                AND_OP, XOR_OP, SHL_OP, SHR_OP, ADD_OP: ctrl = '{
                    writeEnable: 1, memRead: 0, memWrite: 0, branch: 0,
                    MemToReg: 0, OP: op
                };
                LW_OP: ctrl = '{
                    writeEnable: 1, memRead: 1, memWrite: 0, branch: 0,
                    MemToReg: 1, OP: op
                };
                SW_OP: ctrl = '{
                    writeEnable: 0, memRead: 0, memWrite: 1, branch: 0,
                    MemToReg: 0, OP: op
                };
                BR_OP: ctrl = '{
                    writeEnable: 0, memRead: 0, memWrite: 0, branch: 1,
                    MemToReg: 0, OP: op
                };
                default: ctrl = '{default: 0, OP: op};
            endcase
        end
    end

endmodule