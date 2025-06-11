module HazardControlMUX (
    input logic writeEnable_in, memRead_in, memWrite_in, branch_in, ALUSrc_in, MemToReg_in,
    input logic [2:0] OP_in,
    input logic stall,
    output logic writeEnable, memRead, memWrite, branch, ALUSrc, MemToReg,
    output logic [2:0] OP
);

    always_comb begin
        if (stall) begin
            writeEnable = 0;
            memRead     = 0;
            memWrite    = 0;
            branch      = 0;
            ALUSrc      = 0;
            MemToReg    = 0;
            OP          = 3'b000;
        end else begin
            writeEnable = writeEnable_in;
            memRead     = memRead_in;
            memWrite    = memWrite_in;
            branch      = branch_in;
            ALUSrc      = ALUSrc_in;
            MemToReg    = MemToReg_in;
            OP          = OP_in;
        end
    end

endmodule