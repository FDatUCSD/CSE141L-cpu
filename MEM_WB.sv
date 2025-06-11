import Defs::*;

module MEM_WB (
    input  logic clk,
    input  logic reset,

    // Control signals
    input  ControlSignals control_in,
    output ControlSignals control_out,

    // Data from memory or ALU
    input  logic [7:0] memData_in,
    input  logic [7:0] ALUResult_in,
    input  logic [2:0] Rd_in,

    output logic [7:0] memData_out,
    output logic [7:0] ALUResult_out,
    output logic [2:0] Rd_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            control_out     <= '0;
            memData_out     <= 8'b0;
            ALUResult_out   <= 8'b0;
            Rd_out          <= 3'b0;
        end else begin
            control_out     <= control_in;
            memData_out     <= memData_in;
            ALUResult_out   <= ALUResult_in;
            Rd_out          <= Rd_in;
        end
    end

endmodule
