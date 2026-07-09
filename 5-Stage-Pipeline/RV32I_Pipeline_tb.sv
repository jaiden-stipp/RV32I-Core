`timescale 1ns/1ps

module tb_RV32I_Pipeline;

    logic clk;
    logic rst;

    RV32I_Pipeline dut (
        .clk(clk),
        .rst(rst)
    );

    string testfile;
    integer cycles;
    integer max_cycles;
    

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        if (!$value$plusargs("TEST=%s", testfile)) begin
            testfile = "programs/fibonacci.hex";
        end
        if (!$value$plusargs("MAX_CYCLES=%d", max_cycles)) begin
            max_cycles = 10000;
        end
        
        $display("Loading program: %s", testfile);
        $readmemh(testfile, dut.IM.mem);

        rst = 1;
        cycles = 0;

        repeat (8) @(posedge clk);
        rst = 0;

    end

    always @(posedge clk) begin
        if (!rst) begin
            cycles <= cycles + 1;

            if (dut.halt) begin
                $display("INSTRUCTION HALT");
                showStats();
                $finish;
            end
            if (dut.DM.mem[0] == 32'd1) begin
                $display("%s Passed", testfile);
                showStats();
                $finish;
            end
            if (dut.DM.mem[0] == 32'd2) begin
                $display("%s Failed :(", testfile);
                showStats();
                $finish;
            end
            if (cycles > max_cycles) begin
                $display("%s TIMEOUT", testfile);
                $display("PC: %h", dut.pc);
                $display("Instruction IF: %h", dut.Instruction);
                $display("Instruction ID: %h", dut.Instruction_ID);
                $display("DM[0]: %h", dut.DM.mem[0]);
                showStats();
                $finish;
            end
        end
    end
    real cpi;
    task showStats;
        begin
            $display("Cycles:  %0d", dut.cycle_counter);
            $display("Instructions: %0d", dut.instruction_counter);
            $display("Stalls:  %0d", dut.stall_counter);
            $display("Flushes: %0d", dut.flush_counter);
            $display("Forwards:  %0d", dut.forward_counter);
            if (dut.instruction_counter != 0) begin
                cpi = real'(dut.cycle_counter) / real'(dut.instruction_counter);
                $display("CPI: %0.2f", cpi);
            end else begin
                $display("CPI: N/A");
            end
        end
    endtask
endmodule