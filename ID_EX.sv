import Defs::*;

module ID_EX(
    input logic clk,
    input logic reset,

    // Control signals (already passed through the hazard MUX)
    input ControlSignals control_in,

    // Operands
    input logic [7:0] RsVal_in, RdVal_in, ImmVal_in,

    // Register IDs
    input logic [2:0] Rs_in, Rd_in,

    // Outputs to EX stage
    // Control signals
    output ControlSignals control_out,

    // Operands
    output logic [7:0] RsVal_out, RdVal_out, ImmVal_out,

    // Register IDs
    output logic [2:0] Rs_out, Rd_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            control_out     <= '0;
            RsVal_out       <= 8'b0;
            RdVal_out       <= 8'b0;
            ImmVal_out      <= 8'b0;
            Rs_out          <= 3'b0;
            Rd_out          <= 3'b0;
        end else begin // Just pass the signals through
            control_out     <= control_in;
            RsVal_out       <= RsVal_in;
            RdVal_out       <= RdVal_in;
            ImmVal_out      <= ImmVal_in;
            Rs_out          <= Rs_in;
            Rd_out          <= Rd_in;
        end
    end

endmodule