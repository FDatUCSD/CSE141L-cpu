module RF(
	input  CLK, regWrite,
	input [2:0] R1, R2,
	input [7:0] writeValue,
	output logic [7:0] val1, val2,
	output logic cmp
	);

	reg [7:0] registers_arr[0:7];

    	// Combinational reads
	assign val1 = registers_arr[R1];
    	assign val2 = registers_arr[R2];
	assign cmp = (registers_arr[R1] == registers_arr[R2]); // for early branch resolution

   	 // Synchronous write to R2
    	always_ff @(posedge CLK) begin
        	if (regWrite) begin
            		registers_arr[R2] <= writeValue;
        	end
    	end

endmodule