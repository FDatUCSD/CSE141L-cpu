module HazardUnit(
    input logic ID_EX_MemRead,
    input logic [2:0] IF_ID_Rs,
    input logic [2:0] ID_EX_Rd,  // previous instruction destination
    output logic stall
);
    always_comb begin
        // If previous instruction is a load and current instruction uses its result
        if (ID_EX_MemRead && (IF_ID_Rs == ID_EX_Rd))
            stall = 1;
        else
            stall = 0;
    end
endmodule
