module ID_EX(
    input logic clk,
    input logic reset,

    // Control signals (already passed through the hazard MUX)
    input logic writeEnable_in, memRead_in, memWrite_in, branch_in, ALUSrc_in, MemToReg_in,
    input logic [2:0] OP_in,

    // Operands
    input logic [7:0] RsVal_in, RdVal_in, ImmVal_in,

    // Register IDs
    input logic [2:0] Rs_in, Rd_in,

    // Outputs to EX stage
    // Control signals
    output logic writeEnable_out, memRead_out, memWrite_out, branch_out, ALUSrc_out, MemToReg_out,
    output logic [2:0] OP_out,

    // Operands
    output logic [7:0] RsVal_out, RdVal_out, ImmVal_out,

    // Register IDs
    output logic [2:0] Rs_out, Rd_out
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            writeEnable_out <= 0;
            memRead_out     <= 0;
            memWrite_out    <= 0;
            branch_out      <= 0;
            ALUSrc_out      <= 0;
            MemToReg_out    <= 0;
            OP_out          <= 3'b000;
            RsVal_out       <= 8'b0;
            RdVal_out       <= 8'b0;
            ImmVal_out      <= 8'b0;
            Rs_out          <= 3'b0;
            Rd_out          <= 3'b0;
        end else begin
            writeEnable_out <= writeEnable_in;
            memRead_out     <= memRead_in;
            memWrite_out    <= memWrite_in;
            branch_out      <= branch_in;
            ALUSrc_out      <= ALUSrc_in;
            MemToReg_out    <= MemToReg_in;
            OP_out          <= OP_in;

            RsVal_out       <= RsVal_in;
            RdVal_out       <= RdVal_in;
            ImmVal_out      <= ImmVal_in;
            Rs_out          <= Rs_in;
            Rd_out          <= Rd_in;
        end
    end

endmodule