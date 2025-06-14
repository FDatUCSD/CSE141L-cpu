module HaltDetector (
    input  logic [8:0] instr_in,       // Instruction from IF/ID
    output logic       halt_detected   // 1 if this is a halt instruction
);

    // Extract opcode (bits 8 to 6)
    logic [2:0] opcode;
    assign opcode = instr_in[8:6];

    // Detect HALT: opcode == 3'b111 && rest == 6'b000000
    always_comb begin
        if (opcode == 3'b111 && instr_in[5:0] == 6'b000000) begin
            $display("Halt instruction detected: %b", instr_in);
            halt_detected = 1'b1;
        end
        else
            halt_detected = 1'b0;
    end

endmodule
