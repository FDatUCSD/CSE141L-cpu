import Defs::*;

module EX_MEM (
    input  logic clk,
    input  logic reset,

    // Inputs
    input  ControlSignals control_in,
    input  logic [7:0] ALUResult_in,
    input  logic [7:0] RdVal_in,
    input  logic [2:0] Rd_in,

    // Outputs
    output ControlSignals control_out,
    output logic [7:0] ALUResult_out,
    output logic [7:0] RdVal_out,
    output logic [2:0] Rd_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            control_out     <= '0;
            ALUResult_out   <= 8'b0;
            RdVal_out       <= 8'b0;
            Rd_out          <= 3'b0;
        end else begin
            control_out     <= control_in;
            ALUResult_out   <= ALUResult_in;
            RdVal_out       <= RdVal_in;
            Rd_out          <= Rd_in;
        end
    end

endmodule
