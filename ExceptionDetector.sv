module ExceptionDetector (
    input  logic [2:0] opcode, rs, rd, // from ID/EX register
    input  logic       exp_error_in,   // Exception error signal from EX stage
    input  logic [7:0] rsVal,        // Value of the source register (r3)
    output logic [1:0]      exception_detected // 1 if an exception is detected
);

    // Detect exceptions based on opcode and exp_error signal
    always_comb begin
        // Default: no exception
        exception_detected = 2'b00;
        // print debug information
        // $display("[ExceptionDetector] Checking opcode: %b, rs: %b, rd: %b, exp_error_in: %b", opcode, rs, rd, exp_error_in);

        if (exp_error_in && opcode == 3'b001 && rd == 3'b000) begin
            if (rs == 3'b011) begin 
                if (rsVal == 8'b0)
                    exception_detected = 2'b01; // return 0x7FFF
                else if (rsVal == 8'b00000001)
                    exception_detected = 2'b10; // return 0x8000
            end
            $display("[ExceptionDetector] Exception detected: %b", exception_detected);
            // print the rest of the debug information
            $display("[ExceptionDetector] Opcode: %b, rs: %b, rd: %b, rsVal: %b", opcode, rs, rd, rsVal);
        end
    end
endmodule