module IF_ID (
    input logic CLK,
    input logic reset,
    input logic stall,         // hold values when asserted
    input logic flush,         // clear values on branch misprediction
    input logic [7:0] PC_in,
    input logic [8:0] instr_in,
    output logic [7:0] PC_out,
    output logic [8:0] instr_out
);

    always_ff @(posedge CLK or posedge reset) begin
        if (reset) begin
            PC_out <= 8'b0;
            instr_out <= 9'b0;
        end
        else if (flush) begin
            PC_out <= 8'b0;
            instr_out <= 9'b0;
        end
        else if (!stall) begin
            PC_out <= PC_in;
            instr_out <= instr_in;
        end
        // If stalled, hold current outputs

        // Debug prints
        $display("[IF/ID] instruction_in: %b", instr_in);
    end

endmodule
