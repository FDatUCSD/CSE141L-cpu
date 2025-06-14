module PageRegister (
    input  logic clk,
    input  logic reset,
    input  logic increment,
    input  logic decrement,
    output logic [2:0] mem_page
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_page <= 5'b0;
        end else begin
            if (increment && !decrement)
                mem_page <= mem_page + 1;
            else if (!increment && decrement)
                mem_page <= mem_page - 1;
            // if both are 0 or both are 1, do nothing
        end
    end

endmodule
