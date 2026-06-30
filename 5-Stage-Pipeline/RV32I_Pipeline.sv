import pipeline_pkg::*;

module RV32I_Pipeline(
    input clk,
    input rst
);
	ctrl_t ctrl_WB, ctrl_ID, ctrl_EX, ctrl_MEM;
    // Stage 1: IF
    logic [31:0] pc, pc_target, Instruction;
    logic pc_src;

    PC_IF pc_if (
        .clk(clk),
        .rst(rst),
        .pc_target(pc_target),
        .pc_src(pc_src),
        .pc(pc)
    );

    InstructionMem IM (
        .pc(pc),
        .Instruction(Instruction)
    );

    // IF/ID register
    logic [31:0] pc_ID, Instruction_ID;

    IF_ID stage1 (
        .clk(clk),
        .rst(rst),
        .pc_IF(pc),
        .Instruction_IF(Instruction),
        .pc_ID(pc_ID),
        .Instruction_ID(Instruction_ID)
    );

    // Stage 2: ID
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    logic [4:0] rdaddr, rs1addr, rs2addr;
    assign opcode = Instruction_ID[6:0];
    assign rdaddr = Instruction_ID[11:7];
    assign funct3 = Instruction_ID[14:12];
    assign rs1addr = Instruction_ID[19:15];
    assign rs2addr = Instruction_ID[24:20];
    assign funct7 = Instruction_ID[31:25];

    logic [2:0] imm_sel;

    ControlUnit CU (
        .opcode(opcode),
        .funct3(funct3),
        .funct7b5(funct7[5]),
        .rdaddr(rdaddr),
        .reg_write(ctrl_ID.reg_write),
        .alu_src(ctrl_ID.alu_src),
        .imm_sel(imm_sel),
        .mem_write(ctrl_ID.mem_write),
        .mem_read(ctrl_ID.mem_read),
        .branch(ctrl_ID.branch),
        .jump(ctrl_ID.jump),
        .jalr(ctrl_ID.jalr),
        .result_src(ctrl_ID.result_src),
        .ALU_Sel(ctrl_ID.ALU_Sel),
        .funct3_o(ctrl_ID.funct3),
        .rdaddr_o(ctrl_ID.rdaddr),
        .pc_sel(ctrl_ID.pc_sel)
    );

    logic [31:0] rs1out, rs2out, wr_data;

    RegFile RF (
        .clk(clk),
        .rs1addr(rs1addr),
        .rs2addr(rs2addr),
        .rdaddr(ctrl_WB.rdaddr),
        .wr_en(ctrl_WB.reg_write),
        .wr_data(wr_data),
        .rs1out(rs1out),
        .rs2out(rs2out)
    );

    logic [31:0] imm_out;

    ImmGen IG (
        .Instruction(Instruction_ID),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    // ID/EX register
    logic [31:0] pc_EX, rs1_EX, rs2_EX, imm_EX;
    logic [4:0] rs1addr_EX, rs2addr_EX;
    

    ID_EX stage2 (
        .clk(clk),
        .rst(rst),
        .rs1addr_ID(rs1addr),
        .rs2addr_ID(rs2addr),
        .pc_ID(pc_ID),
        .rs1out(rs1out),
        .rs2out(rs2out),
        .imm_out(imm_out),
        .ctrl_ID(ctrl_ID),
        .pc_EX(pc_EX),
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),
        .imm_EX(imm_EX),
        .rs1addr_EX(rs1addr_EX),
        .rs2addr_EX(rs2addr_EX),
        .ctrl_EX(ctrl_EX)
    );

    // Stage 3: EX
    logic [31:0] ALU_A, ALU_B, Q;
    logic Zero;

    assign ALU_A = ctrl_EX.pc_sel ? pc_EX : rs1_EX;
    assign ALU_B = ctrl_EX.alu_src ? imm_EX : rs2_EX;

    ALU alu (
        .A(ALU_A),
        .B(ALU_B),
        .ALU_Sel(ctrl_EX.ALU_Sel),
        .Q(Q),
        .Zero(Zero)
    );

    // EX/MEM register
    logic [31:0] pc_MEM, rs2_MEM, imm_MEM, Q_MEM;
    logic Zero_MEM;
    

    EX_MEM stage3 (
        .clk(clk),
        .rst(rst),
        .pc_EX(pc_EX),
        .rs2_EX(rs2_EX),
        .imm_EX(imm_EX),
        .Q_EX(Q),
        .Zero(Zero),
        .ctrl_EX(ctrl_EX),
        .pc_MEM(pc_MEM),
        .rs2_MEM(rs2_MEM),
        .imm_MEM(imm_MEM),
        .Q_MEM(Q_MEM),
        .Zero_MEM(Zero_MEM),
        .ctrl_MEM(ctrl_MEM)
    );

    // Stage 4: MEM
    logic [31:0] mem_rdata;

    DataMem DM (
        .clk(clk),
        .dm_addr(Q_MEM),
        .wdata(rs2_MEM),
        .w_en(ctrl_MEM.mem_write),
        .r_en(ctrl_MEM.mem_read),
        .rdata(mem_rdata)
    );

    PC_MEM pc_mem (
        .jump(ctrl_MEM.jump),
        .jalr(ctrl_MEM.jalr),
        .branch(ctrl_MEM.branch),
        .Zero(Zero_MEM),
        .funct3(ctrl_MEM.funct3),
        .imm_MEM(imm_MEM),
        .Q_MEM(Q_MEM),
        .pc_MEM(pc_MEM),
        .pc_target(pc_target),
        .pc_src(pc_src)
    );

    // MEM/WB register
    logic [31:0] Q_WB, rdata_WB, pc_WB;
    

    MEM_WB stage4 (
        .clk(clk),
        .rst(rst),
        .Q_MEM(Q_MEM),
        .rdata(mem_rdata),
        .pc_MEM(pc_MEM),
        .ctrl_MEM(ctrl_MEM),
        .Q_WB(Q_WB),
        .rdata_WB(rdata_WB),
        .pc_WB(pc_WB),
        .ctrl_WB(ctrl_WB)
    );

    // Stage 5: WB
    ResultMux RM (
        .result_src(ctrl_WB.result_src),
        .Q(Q_WB),
        .mem_rdata(rdata_WB),
        .pc_plus4(pc_WB + 32'd4),
        .wr_data(wr_data)
    );

endmodule
