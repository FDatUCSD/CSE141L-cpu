module DataMemMUX (
    input logic sel, // 0 for data from EX/MEM register, 1 for data forwarded from WB stage
    input logic [7:0] exMem_data, // Data from EX/MEM stage
    input logic [7:0] wb_data, // Data from WB stage
    output logic [7:0] data_out // Output data
);

    always_comb begin
        case (sel)
            1'b0: data_out = exMem_data; // Use data from EX/MEM stage
            1'b1: data_out = wb_data; // Use data from WB stage
            default: data_out = 8'b0; // Default case (should not happen)
        endcase
    end
endmodule
