module InstructionMemory (
    input  logic [9:0] address,          // PC
    output logic [8:0] instruction       // 9-bit instruction output
);

    logic [8:0] memory [0:1023];          // 1024 x 9-bit ROM

    // Load machine code (binary format) from assembler output file
    initial begin
        $readmemb("instr_mem.bin", memory);  // Your assembler should output this file
    end

    assign instruction = memory[address];

endmodule
