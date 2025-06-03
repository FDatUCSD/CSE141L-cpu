module Control(
	input init,
	input [8:0] instruction,
	output logic writeEnable, // write to RF
	output logic [2:0] OP, // ALU operation
	output logic memRead, // load from memory
	output logic memWrite, // store into memory
	output logic branch // 1 if branching
	);

	always_comb begin
		if(init) begin
			writeEnable = 0;
			OP = instruction[8:6];
			memRead = 0;
			memWrite = 0;
			branch = 0;
		end else begin
			OP = instruction[8:6];

			case(instruction[8:6])
				3'b000: begin // and
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
				end

				3'b001: begin // xor
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
				end

				3'b010: begin // shl
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
				end

				3'b011: begin // shr
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
				end
				3'b100: begin // add
					writeEnable = 1;
					memRead = 0;
					memWrite = 0;
					branch = 0;
				end