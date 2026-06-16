module RV32I_tb;
    logic clk;
    logic rst;
    RV32I_Single dut (
        .clk(clk),
        .rst(rst)
    );
    initial clk = 0;
    always #10 clk = ~clk;

    
    initial begin
        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;
        repeat(5) @(posedge clk);  // let 3+ instructions execute
        #1;
        $monitor( "Time is %0t : Instruction = %h   Reset = %b   PC = %h  ALU A = %h  ALU B = %h ALU Out = %h", $stime, dut.Instruction, rst, dut.pc, dut.ALU_A, dut.ALU_B, dut.Q);

        assert(dut.RF.registers[1] == 32'd5)
        else $error("Register 1 failed to write, expected 5 got %0d", dut.RF.registers[1]);
        assert(dut.RF.registers[2] == 32'd7)
        else $error("Register 2 failed to write, expected 7 got %0d", dut.RF.registers[2]);

        assert(dut.RF.registers[3] == 32'd12)
        else $error("Add operation failed, expected 12 got %0d", dut.RF.registers[3]);
        $stop;
    end

endmodule