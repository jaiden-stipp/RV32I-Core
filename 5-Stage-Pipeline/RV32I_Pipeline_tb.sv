`timescale 1ns/1ps

module RV32I_Pipeline_tb;

    logic clk;
    logic rst;

    RV32I_Pipeline dut (
        .clk(clk),
        .rst(rst)
    );

    string testfile;
    integer cycles;
    integer max_cycles;
    localparam int TEST_STATUS_WORD = 32'h0000_F000 >> 2;
    

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
        $readmemh(testfile, dut.UM.mem);
        dut.UM.mem[TEST_STATUS_WORD] = 32'd0;

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
            if (dut.ctrl_MEM.mem_write && dut.ALU_result_MEM < 32'h00000200) begin
                $warning("Store to low/code memory: addr=%h data=%h pc_MEM=%h", dut.ALU_result_MEM, dut.rs2_MEM, dut.pc_MEM);
                showStats();
                $finish;
            end
            if (dut.misaligned) begin
                $warning("Misaligned memory access: addr=%h data=%h funct3=%b pc_MEM=%h", dut.ALU_result_MEM, dut.rs2_MEM, dut.ctrl_MEM.funct3, dut.pc_MEM);
                showStats();
                $finish;
            end
            if (dut.UM.mem[TEST_STATUS_WORD] == 32'd1) begin
                $display("%s Passed", testfile);
                showStats();
                $finish;
            end
            if (dut.UM.mem[TEST_STATUS_WORD] == 32'd2) begin
                $display("%s Failed :(", testfile);
                showStats();
                $finish;
            end
            if (cycles > max_cycles) begin
                $display("%s TIMEOUT", testfile);
                $display("PC: %h", dut.pc);
                $display("Instruction IF: %h", dut.Instruction);
                $display("Instruction ID: %h", dut.Instruction_ID);
                $display("TEST_STATUS[0x0000_F000]: %h", dut.UM.mem[TEST_STATUS_WORD]);
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
