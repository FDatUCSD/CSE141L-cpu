module RF(
	input  CLK, regWrite,
	input [2:0] Rs, Rd,
	input [7:0] writeValue,
	output logic [7:0] RsVal, RdVal,
	output logic cmp
	);

	reg [7:0] registers_arr[0:7];

    	// Combinational reads
	assign RsVal = registers_arr[Rs];
	assign RdVal = registers_arr[Rd];
	assign cmp = (registers_arr[Rs] == 8'b0); // for early branch resolution

   	 // Synchronous write to Rd
    	always_ff @(posedge CLK) begin
        	if (regWrite) begin
            		registers_arr[Rd] <= writeValue;
        	end
    	end

endmodule