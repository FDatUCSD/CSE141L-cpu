module ExceptionRegister(
    input logic clk,
    input logic reset,
    input logic [1:0] exp_error_in, // Exception error signal from EX stage
    output logic [1:0] exp_error_out // Output exception error from MEM stage
);

    // Register to hold the exception code
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            exp_error_out <= 2'b00; // Reset exception error to no exception
        end else begin
            // Update the exception error register with the latest value from EX or MEM stage
            exp_error_out <= exp_error_in;
            // $display("[ExceptionRegister] Exception error updated: %b", exp_error_out);
        end
    end
endmodule