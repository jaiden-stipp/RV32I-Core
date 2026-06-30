import pipeline_pkg::*;

module EX_MEM(
    input logic clk, rst,
    input logic [31:0] pc_EX, rs2_EX, imm_EX, Q_EX,
    input logic Zero,
    input ctrl_t ctrl_EX,
    output logic [31:0] pc_MEM, rs2_MEM, imm_MEM, Q_MEM,
    output logic Zero_MEM,
    output ctrl_t ctrl_MEM
);
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_MEM <= 32'b0;
            rs2_MEM <= 32'b0;
            imm_MEM <= 32'b0;
            Q_MEM <= 32'b0;
            Zero_MEM <= 1'b0;
            ctrl_MEM <= '0;
        end else begin
            pc_MEM <= pc_EX;
            rs2_MEM <= rs2_EX;
            imm_MEM <= imm_EX;
            Q_MEM <= Q_EX;
            Zero_MEM <= Zero;
            ctrl_MEM <= ctrl_EX;
        end
    end
endmodule
