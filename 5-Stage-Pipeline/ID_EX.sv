import pipeline_pkg::*;

module ID_EX(
    input logic clk, rst,
    input logic [4:0] rs1addr_ID, rs2addr_ID,
    input logic [31:0] pc_ID, rs1out, rs2out, imm_out,
    input ctrl_t ctrl_ID,
    output logic [31:0] pc_EX, rs1_EX, rs2_EX, imm_EX,
    output logic [4:0] rs1addr_EX, rs2addr_EX, 
    output ctrl_t ctrl_EX
);
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_EX <= 32'b0;
            rs1_EX <= 32'b0;
            rs2_EX <= 32'b0;
            imm_EX <= 32'b0;
            ctrl_EX <= '0;
        end else begin
            pc_EX <= pc_ID;
            rs1_EX <= rs1out;
            rs2_EX <= rs2out;
            imm_EX <= imm_out;
            ctrl_EX <= ctrl_ID;
        end
    end
endmodule
