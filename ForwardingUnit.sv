module ForwardingUnit (
    input logic [2:0] EX_Rs, EX_Rd,
    input logic [2:0] MEM_Rd, WB_Rd,
    input logic       MEM_RegWrite, WB_RegWrite,
    output logic [1:0] ForwardA, ForwardB
);

    always_comb begin
        // Default to no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // ForwardA logic (EX_Rs)
        if (MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rs))
            ForwardA = 2'b10; // Forward from EX/MEM
        else if (WB_RegWrite && (WB_Rd != 0) && (WB_Rd == EX_Rs))
            ForwardA = 2'b01; // Forward from MEM/WB

        // ForwardB logic (EX_Rd)
        if (MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rd))
            ForwardB = 2'b10; // Forward from EX/MEM
        else if (WB_RegWrite && (WB_Rd != 0) && (WB_Rd == EX_Rd))
            ForwardB = 2'b01; // Forward from MEM/WB
    end

endmodule
