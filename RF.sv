module RF(
	input  CLK, regWrite, reset,
	input [2:0] Rs, Rd,
	input [7:0] writeValue,
	input [2:0] writeAddr,
	output logic [7:0] RsVal, RdVal
	);

	reg [7:0] registers_arr[0:7];

	// Internal forwarding logic
	always_comb begin

		// If reading from register 0, always return 0
		RsVal = (Rs == 3'b000) ? 8'b0 :
		        (regWrite && (Rs == writeAddr)) ? writeValue : registers_arr[Rs];

		RdVal = (Rd == 3'b000) ? 8'b0 :
		        (regWrite && (Rd == writeAddr)) ? writeValue : registers_arr[Rd];

		// Debug: print reads
    	// $display("[RF comb] Rs: %0d => %0d | Rd: %0d => %0d | regWrite: %b | writeAddr: %0d | writeValue: %0d", 
        //       Rs, RsVal, Rd, RdVal, regWrite, writeAddr, writeValue);
	end

   	 // Synchronous write to Rd
    	always_ff @(posedge CLK) begin
			if (reset) begin
				// Synchronous reset
				registers_arr[0] <= 0;
				registers_arr[1] <= 0;
				registers_arr[2] <= 0;
				registers_arr[3] <= 0;
				registers_arr[4] <= 0;
				registers_arr[5] <= 0;
				registers_arr[6] <= 0;
				registers_arr[7] <= 0;
			end
        	if (regWrite) begin
            		registers_arr[writeAddr] <= writeValue;
        	end
			registers_arr[0] <= 8'b0;
    	end

endmodule