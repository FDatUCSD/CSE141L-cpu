module BranchPage (
    input  logic clk,
    input  logic reset,
    input  logic increment,
    input  logic decrement,
    output logic [2:0] mem_page
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_page <= 3'b0;
        end else begin
            if (increment && !decrement) begin
            $display("Incrementing mem_page: %d", mem_page);
                mem_page <= mem_page + 1;
            end
            else if (!increment && decrement) begin
            $display("Decrementing mem_page: %d", mem_page);
                mem_page <= mem_page - 1;
            // if both are 0 or both are 1, do nothing
            end
        end
    end
endmodule