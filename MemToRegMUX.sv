module MemToRegMUX (
    input  logic [7:0] alu_result,
    input  logic [7:0] mem_data,
    input  logic       memToReg,     // 0 = alu_result, 1 = mem_data
    output logic [7:0] write_data
);

    always_comb begin
        case (memToReg)
            1'b0: write_data = alu_result;
            1'b1: write_data = mem_data;
        endcase
    end

endmodule
