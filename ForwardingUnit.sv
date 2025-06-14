import Defs::*;

module ForwardingUnit (
    input logic [2:0] EX_Rs, EX_Rd,
    input logic [2:0] MEM_Rd, WB_Rd,
    input logic [2:0] Branch_Rs,
    input logic       MEM_RegWrite, WB_RegWrite,
    output ForwardSel ForwardA, ForwardB, ForwardBranch, 
    output logic      ForwardMem
);

    always_comb begin
        // ForwardA logic
        if (MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rs)) begin
            ForwardA = FORWARD_MEM;
        end
        else if (WB_RegWrite && (WB_Rd != 0) &&
                !(MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rs)) &&
                (WB_Rd == EX_Rs)) begin
            ForwardA = FORWARD_WB;
        end
        else begin
            ForwardA = FORWARD_NONE;
        end

        // ForwardB logic
        if (MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rd)) begin
            ForwardB = FORWARD_MEM;
        end
        else if (WB_RegWrite && (WB_Rd != 0) &&
                !(MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rd)) &&
                (WB_Rd == EX_Rd)) begin
            ForwardB = FORWARD_WB;
        end
        else begin
            ForwardB = FORWARD_NONE;
        end

        // ForwardBranch logic
        if (MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == Branch_Rs)) begin
            ForwardBranch = FORWARD_MEM;
        end
        else if (WB_RegWrite && (WB_Rd != 0) &&
                !(MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == Branch_Rs)) &&
                (WB_Rd == Branch_Rs)) begin
            ForwardBranch = FORWARD_WB;
        end
        else begin
            ForwardBranch = FORWARD_NONE;
        end

        // ForwardMem logic
        if (WB_RegWrite && (WB_Rd != 0) && (WB_Rd == MEM_Rd)) begin
            // $display("[fwdUnit] WB_RegWrite = %b", WB_RegWrite);
            ForwardMem = 1;
        end else begin
            ForwardMem = 0;
        end

        // print control signals for debugging from pipeline registers
        // $display("[fwdUnit] MEM_RegWrite = %b, MEM_Rd = %d, WB_RegWrite = %b, WB_Rd = %d, ForwardA = %b, ForwardB = %b, ForwardBranch = %b, ForwardMem = %b",
        //          MEM_RegWrite, MEM_Rd, WB_RegWrite, WB_Rd,
        //          ForwardA, ForwardB, ForwardBranch, ForwardMem);
    end

endmodule
