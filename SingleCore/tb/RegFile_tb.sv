module RegFile_tb;
    logic clk, wr_en;
    logic [31:0] wr_data, rs1out, rs2out;
    logic [4:0] rs1addr, rs2addr, rdaddr;

    RegFile dut (
        .clk(clk),
        .rs1addr(rs1addr),
        .rs2addr(rs2addr),
        .rdaddr(rdaddr),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rs1out(rs1out),
        .rs2out(rs2out)
    );

    initial clk = 0;
    always #10 clk = ~clk;

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
        rs1addr = 0; rs2addr = 0; rdaddr = 0; wr_en = 0; wr_data = 0;
        @(posedge clk); #1;

        // Write x1=, x2=2, x3=3,
        wr_en = 1;
        rdaddr = 5'd1; wr_data = 32'hDEADBEEF; @(posedge clk); #1;
        rdaddr = 5'd2; wr_data = 32'h12345678; @(posedge clk); #1;
        rdaddr = 5'd3; wr_data = 32'hA5A5A5A5; @(posedge clk); #1;
        
        wr_en = 0;

        // Read back x1 and x2
        rs1addr = 5'd1; rs2addr = 5'd2; #1;
        check("read x1", rs1out, 32'hDEADBEEF);
        check("read x2", rs2out, 32'h12345678);

        // Read two different regs simultaneously
        rs1addr = 5'd3; rs2addr = 5'd4; #1;
        check("simultaneous read x3", rs1out, 32'hA5A5A5A5);
        check("simultaneous read x4", rs2out, 32'h12345678);

        // x0 always reads as 0
        rs1addr = 5'd0; #1;
        check("x0 reads zero", rs1out, 32'd0);

        // Write to x0 — should be ignored
        wr_en = 1; rdaddr = 5'd0; wr_data = 32'hFFFFFFFF;
        @(posedge clk); #1;
        wr_en = 0;
        rs1addr = 5'd0; #1;
        check("x0 write ignored", rs1out, 32'd0);

        // Disabled write does not corrupt a register
        wr_en = 0; rdaddr = 5'd1; wr_data = 32'h00000000;
        @(posedge clk); #1;
        rs1addr = 5'd1; #1;
        check("disabled write no corrupt", rs1out, 32'hDEADBEEF);

        $display("-----------------------------");
        $display("%0d/%0d tests passed", pass, pass+fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
