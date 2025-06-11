module InstructionMemory (
    input  logic [7:0] address,          // PC
    output logic [8:0] instruction       // 9-bit instruction output
);

    logic [8:0] memory [0:255];          // 256 x 9-bit ROM

    // Load machine code (binary format) from assembler output file
    initial begin
        $readmemb("instr_mem.bin", memory);  // Your assembler should output this file
    end

    assign instruction = memory[address];

endmodule
