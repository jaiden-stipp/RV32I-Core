module ALU_tb;
    logic [31:0] A, B, Q;
    logic [3:0] ALU_Sel;
    logic Zero;

    ALU dut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Q(Q),
        .Zero(Zero)
    );

    int pass = 0, fail = 0;

    task check(input string name, input logic [31:0] got, input logic [31:0] exp);
        if (got === exp) begin
            $display("[PASS] %s", name);
            pass++;
        end else begin
            $display("[FAIL] %s — expected %h, got %h", name, exp, got);
            fail++;
        end
    endtask

    initial begin
        A = 0; B = 0; ALU_Sel = 0;
        #1;

        // ADD
        A = 50; B = 100; ALU_Sel = 4'b0000; #1;
        check("ADD 50 + 100", Q, 32'd150);
        check("ADD 50+100 zero flag", {31'b0, Zero}, 32'd0);

        // ADD overflow wraps/truncates to 32 bits
        A = {32{1'b1}}; B = 10; ALU_Sel = 4'b0000; #1;
        check("ADD Overflow", Q, 32'd9);

        // SUB: a < b, result wraps to negative (two's complement)
        A = 3; B = 5; ALU_Sel = 4'b0001; #1;
        check("SUB a<b wraps", Q, 32'hFFFF_FFFE);
        check("SUB a<b zero flag", {31'b0, Zero}, 32'd0);

        // SUB: a == b, zero flag asserts
        A = 10; B = 10; ALU_Sel = 4'b0001; #1;
        check("SUB a==b result", Q, 32'd0);
        check("SUB a==b zero flag", {31'b0, Zero}, 32'd1);

        // AND
        A = 32'hF0F0_F0F0; B = 32'h0FF0_0FF0; ALU_Sel = 4'b0010; #1;
        check("AND", Q, 32'h00F0_00F0);

        // OR
        A = 32'hF0F0_F0F0; B = 32'h0F0F_0F0F; ALU_Sel = 4'b0011; #1;
        check("OR", Q, 32'hFFFF_FFFF);

        // XOR
        A = 32'hFFFF_0000; B = 32'h0F0F_0F0F; ALU_Sel = 4'b0100; #1;
        check("XOR", Q, 32'hF0F0_0F0F);

        // SLT vs SLTU: a = -1 (signed), b = 1
        A = {32{1'b1}}; B = 1; ALU_Sel = 4'b0101; #1;
        check("SLT (-1 < 1 signed)", Q, 32'd1);

        A = {32{1'b1}}; B = 1; ALU_Sel = 4'b0110; #1;
        check("SLTU (large unsigned not < 1)", Q, 32'd0);

        // SLL
        A = 32'h0000_0001; B = 4; ALU_Sel = 4'b0111; #1;
        check("SLL", Q, 32'h0000_0010);

        // SRL vs SRA on 0x8000_0000 >> 4
        A = 32'h8000_0000; B = 4; ALU_Sel = 4'b1000; #1;
        check("SRL", Q, 32'h0800_0000);

        A = 32'h8000_0000; B = 4; ALU_Sel = 4'b1001; #1;
        check("SRA", Q, 32'hF800_0000);

        // Shift amounts masked to 5 bits: shift by 33 == shift by 1
        A = 32'h0000_0001; B = 33; ALU_Sel = 4'b0111; #1;
        check("SLL shift amount masked (33 == 1)", Q, 32'h0000_0002);

        // PASSB (used for LUI) — result is just b
        A = 32'hDEAD_BEEF; B = 32'h1234_5678; ALU_Sel = 4'b1010; #1;
        check("PASSB", Q, 32'h1234_5678);

        // zero flag only reflects result == 0, not equal-but-nonzero inputs
        A = 5; B = 5; ALU_Sel = 4'b0010; #1; // AND of equal nonzero inputs
        check("AND of equal nonzero inputs", Q, 32'd5);
        check("zero flag false for equal nonzero inputs", {31'b0, Zero}, 32'd0);

        $display("-----------------------------");
        $display("%0d/%0d tests passed", pass, pass+fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule