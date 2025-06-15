module ALU_tb;

    logic [2:0] OP;
    logic [7:0] R1, R2, OUT;
    logic [1:0] OVERFLOW;
    logic ZF;

    ALU dut (
        .OP(OP),
        .R1(R1),
        .R2(R2),
        .OUT(OUT),
        .OVERFLOW(OVERFLOW),
        .ZF(ZF)
    );

    task check(input string name, input [7:0] expected_out, input [1:0] expected_ovf, input expected_zf);
        if (OUT !== expected_out || OVERFLOW !== expected_ovf || ZF !== expected_zf) begin
            $display("FAIL: %s => OUT: %b (expected %b), OVERFLOW: %b (expected %b), ZF: %b (expected %b)",
                     name, OUT, expected_out, OVERFLOW, expected_ovf, ZF, expected_zf);
        end else begin
            $display("PASS: %s", name);
        end
    endtask

    initial begin
        // AND
        OP = 3'b000; R1 = 8'b10101010; R2 = 8'b11001100;
        #1; check("AND", 8'b10001000, 0, 0);

        // XOR
        OP = 3'b001; R1 = 8'b10101010; R2 = 8'b11001100;
        #1; check("XOR", 8'b01100110, 0, 0);

        // SHL (corrected)
        OP = 3'b010; R1 = 8'b10000000; R2 = 8'b00001111;
        #1; check("SHL", 8'b00011111, 0, 0);  // Corrected expected output

        // SHR
        OP = 3'b011; R1 = 8'b00000001; R2 = 8'b11110000;
        #1; check("SHR", 8'b00000000, 0, 1);  // R1[0] is 1, R2[7:1] is 1111000

        // ADD without overflow
        OP = 3'b100; R1 = 8'd10; R2 = 8'd20;
        #1; check("ADD no overflow", 8'd30, 0, 0);

        // ADD with overflow
        OP = 3'b100; R1 = 8'hFF; R2 = 8'h02;
        #1; check("ADD overflow", 8'h01, 2'b01, 0);

        // ADD result zero
        OP = 3'b100; R1 = 8'd200; R2 = 8'd56; // 200 + 56 = 256 -> 0
        #1; check("ADD zero", 8'd0, 2'b01, 1);

        $display("ALU tests finished.");
        $finish;
    end

endmodule
