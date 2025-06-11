module MemToRegMUX (
    input  logic [7:0] aluResult,
    input  logic [7:0] memResult,
    input  logic       sel,     // 0 = aluResult, 1 = memResult
    output logic [7:0] out
);

    always_comb begin
        case (sel)
            1'b0: out = aluResult;
            1'b1: out = memResult;
        endcase
    end

endmodule
