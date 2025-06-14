module DataMemory (
    input  logic        clk,
    input  logic        memRead,
    input  logic        memWrite,
    input  logic [7:0]  address,
    input  logic [7:0]  writeData,
    output logic [7:0]  readData
);

    logic [7:0] mem_core [0:255];  // 256 x 8-bit memory array

    initial 
        $readmemh("dataram_init.list", mem_core);

    // Read: Combinational
    always_comb begin
        // $display("[DataMemory] memRead = %b, memWrite = %b, address = %h, writeData = %h", memRead, memWrite, address, writeData);
        if (memRead)
            readData = mem_core[address];
        else
            readData = 8'bZ;
    end

    // Write: Synchronous
    always_ff @(posedge clk) begin
        if (memWrite) begin
            // $display("Writing %h to address %h", writeData, address);
            mem_core[address] <= writeData;
        end
    end

endmodule