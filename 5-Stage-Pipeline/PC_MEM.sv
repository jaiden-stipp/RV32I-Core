module PC_MEM(
    input logic jump, jalr, branch, ALU_Zero,
    input logic [2:0] funct3,
    input logic [31:0] imm_MEM, ALU_result_MEM, pc_MEM,
    output logic [31:0] pc_target,
    output logic pc_src
);
    // JALR target = rs1+imm, which the EX ALU already computed into ALU_result_MEM.
    // JAL/branch target = pc + imm (B/J-type offset carried through EX_MEM).
    assign pc_target = jalr ? ALU_result_MEM : (pc_MEM + imm_MEM);
    assign pc_src    = jump | (branch & ((funct3[2] ? ~ALU_Zero : ALU_Zero) ^ funct3[0]));
endmodule
