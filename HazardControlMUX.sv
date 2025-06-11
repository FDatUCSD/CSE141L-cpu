import Defs::*;

module HazardControlMUX (
    input ControlSignals control_in,
    input logic stall,
    output ControlSignals control_out
);

    always_comb begin
        if (stall) begin
            control_out = '{default: 0};
        end else begin
            control_out = control_in;
        end
    end

endmodule