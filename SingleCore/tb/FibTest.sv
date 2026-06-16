module FibTest;

    logic clk, rst;

    RV32I_Single dut (
        .clk(clk),
        .rst(rst)
    );

    // 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Expected fibonacci sequences
    logic [31:0] expected_x6 [0:10] = '{
        32'd0,  32'd1,  32'd1,  32'd2,  32'd3,
        32'd5,  32'd8,  32'd13, 32'd21, 32'd34, 32'd55
    };
    int write_num = 0;
    int pass_count = 0, fail_count = 0;

    // Fire every time x6 is written; compare actual write data to expected
    always @(posedge clk) begin
        if (!rst && dut.RF.wr_en && dut.RF.rdaddr == 5'd6) begin
            if (dut.RF.wr_data === expected_x6[write_num])
                $display("PASS  write %2d: x6 = %3d  (expected %3d)",
                         write_num, dut.RF.wr_data, expected_x6[write_num]);
            else
                $display("FAIL  write %2d: x6 = %3d  (expected %3d)",
                         write_num, dut.RF.wr_data, expected_x6[write_num]);
            write_num++;
        end
    end

    initial begin
        // Assert reset for 2 cycles
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // 65 cycles to reach done + margin
        repeat(80) @(posedge clk);

        $display("\nFibTest Results");
        $display("x6(t1) = %0d  (expected 55)",  dut.RF.registers[6]);
        $display("x7(t2) = %0d  (expected 89)",  dut.RF.registers[7]);
        $display("PC     = %0h  (expected 28)",   dut.pc);

        $finish;
    end

endmodule