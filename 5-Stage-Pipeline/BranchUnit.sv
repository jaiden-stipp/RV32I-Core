module BranchUnit(
    input logic jump, jalr, branch, ALU_Zero,
    input logic [2:0] funct3,
    input logic [31:0] imm_EX, ALU_result, pc_EX,
    output logic [31:0] pc_target,
    output logic pc_src
);
    assign pc_target = jalr ? ALU_result_EX : (pc_EX + imm_EX);
    assign pc_src = jump | (branch & ((funct3[2] ? ~ALU_Zero : ALU_Zero) ^ funct3[0]));
endmodule
