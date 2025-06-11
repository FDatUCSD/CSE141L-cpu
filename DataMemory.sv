module DataMemory (
    input  logic        clk,
    input  logic        memRead,
    input  logic        memWrite,
    input  logic [7:0]  address,
    input  logic [7:0]  writeData,
    output logic [7:0]  readData
);

    logic [7:0] memory [0:255];  // 256 x 8-bit memory array

    // Read: Combinational
    always_comb begin
        if (memRead)
            readData = memory[address];
        else
            readData = 8'b0;
    end

    // Write: Synchronous
    always_ff @(posedge clk) begin
        if (memWrite)
            memory[address] <= writeData;
    end

endmodule