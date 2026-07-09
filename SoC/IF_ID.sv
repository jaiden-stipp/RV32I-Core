module IF_ID(
    input logic clk, rst, stall, flush,
    input logic [31:0] Instruction_IF, pc_IF,
    output logic [31:0] Instruction_ID, pc_ID
);
    always_ff @(posedge clk) begin
        if (rst || flush) begin 
            Instruction_ID <= 32'h00000013; //addi x0, x0, 0 aka NOP
            pc_ID <= 32'b0;
        end else if (!stall) begin
            Instruction_ID <= Instruction_IF;
            pc_ID <= pc_IF;
        end
    end
endmodule