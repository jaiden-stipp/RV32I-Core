import pipeline_pkg::*;

module MEM_WB(
    input logic clk, rst,
    input logic [31:0] ALU_result_MEM, rdata, pc_MEM,
    input ctrl_t ctrl_MEM,
    output logic [31:0] ALU_result_WB, rdata_WB, pc_WB,
    output ctrl_t ctrl_WB
);
    always_ff @(posedge clk) begin
        if (rst) begin
            ALU_result_WB <= 32'b0;
            rdata_WB <= 32'b0;
            pc_WB <= 32'b0;
            ctrl_WB <= '0;
        end else begin
            ALU_result_WB <= ALU_result_MEM;
            rdata_WB <= rdata;
            pc_WB <= pc_MEM;
            ctrl_WB <= ctrl_MEM;
        end
    end
endmodule
