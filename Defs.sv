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

endpackage
