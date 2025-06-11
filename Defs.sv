package Defs;

    typedef struct packed {
        logic writeEnable;
        logic memRead;
        logic memWrite;
        logic branch;
        logic ALUSrc;
        logic MemToReg;
        logic [2:0] OP;
    } ControlSignals;

    typedef enum logic [1:0] {
        FORWARD_NONE = 2'b00,   // Use register file
        FORWARD_MEM  = 2'b10,   // Forward from EX/MEM
        FORWARD_WB   = 2'b01    // Forward from MEM/WB
    } ForwardSel;
 
	typedef enum logic [2:0] {
		AND_OP  = 3'b000,
		XOR_OP  = 3'b001,
		SHL_OP  = 3'b010,
		SHR_OP  = 3'b011,
		ADD_OP  = 3'b100,
		LW_OP   = 3'b101,
		SW_OP   = 3'b110,
		BR_OP   = 3'b111
	} opcode_t;

endpackage
