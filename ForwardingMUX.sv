import Defs::*;

module ForwardingMUX (
    input  logic [7:0] regVal,       // Value from register file
    input  logic [7:0] memVal,       // Forwarded value from EX/MEM stage
    input  logic [7:0] wbVal,        // Forwarded value from MEM/WB stage
    input  ForwardSel forwardSel,    // Control signal for forwarding
    output logic [7:0] operandOut    // Resulting operand value
);

    always_comb begin
        case (forwardSel)
            FORWARD_NONE: operandOut = regVal;
            FORWARD_MEM:  operandOut = memVal;
            FORWARD_WB:   operandOut = wbVal;
            default:      operandOut = regVal;
        endcase
    end

endmodule
