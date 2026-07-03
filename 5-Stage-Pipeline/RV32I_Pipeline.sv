import pipeline_pkg::*;

module RV32I_Pipeline(
    input clk,
    input rst
);
	ctrl_t ctrl_WB, ctrl_ID, ctrl_EX, ctrl_MEM;
    // Stage 1: IF
    logic [31:0] pc, pc_target, Instruction;
    logic pc_src, stall;

    PC_IF pc_if (
        .clk(clk),
        .rst(rst),
        .pc_target(pc_target),
        .pc_src(pc_src),
        .stall(stall),
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
        .stall(stall),
        .flush(pc_src),
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
        .rst(rst),
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
    HazardUnit HU (
        .id_ex_mem_read(ctrl_EX.mem_read),
        .id_ex_rdaddr(ctrl_EX.rdaddr),
        .if_id_rs1addr(rs1addr),
        .if_id_rs2addr(rs2addr),
        .stall(stall)
    );
    // ID/EX register
    logic [31:0] pc_EX, rs1_EX, rs2_EX, imm_EX;
    logic [4:0] rs1addr_EX, rs2addr_EX;
    

    ID_EX stage2 (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(pc_src),
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
    logic [31:0] ALU_A, ALU_B, ALU_result;
    logic ALU_Zero;
    // Forwarding Unit extras
    logic [31:0] rs1_forward, rs2_forward;
    logic [1:0] forwardA_sel, forwardB_sel;
    logic [31:0] pc_MEM, rs2_MEM, imm_MEM, ALU_result_MEM;
    
    ForwardMux Afw (
        .forwardSel(forwardA_sel),
        .reg_data_EX(rs1_EX),
        .ALU_result_MEM(ALU_result_MEM),
        .wr_data(wr_data),
        .reg_data_forward(rs1_forward)
    );
    ForwardMux Bfw (
        .forwardSel(forwardB_sel),
        .reg_data_EX(rs2_EX),
        .ALU_result_MEM(ALU_result_MEM),
        .wr_data(wr_data),
        .reg_data_forward(rs2_forward)
    );
    assign ALU_A = ctrl_EX.pc_sel ? pc_EX : rs1_forward;
    assign ALU_B = ctrl_EX.alu_src ? imm_EX : rs2_forward;

    
    ALU alu (
        .A(ALU_A),
        .B(ALU_B),
        .ALU_Sel(ctrl_EX.ALU_Sel),
        .ALU_result(ALU_result),
        .ALU_Zero(ALU_Zero)
    );
    
    logic ALU_Zero_MEM;
    BranchUnit BU (
        .jump(ctrl_EX.jump),
        .jalr(ctrl_EX.jalr),
        .branch(ctrl_EX.branch),
        .ALU_Zero(ALU_Zero),
        .funct3(ctrl_EX.funct3),
        .imm_EX(imm_EX),
        .ALU_result(ALU_result),
        .pc_EX(pc_EX),
        .pc_target(pc_target),
        .pc_src(pc_src)
    );
    // EX/MEM register
    EX_MEM stage3 (
        .clk(clk),
        .rst(rst),
        .pc_EX(pc_EX),
        .rs2_EX(rs2_forward),
        .imm_EX(imm_EX),
        .ALU_result_EX(ALU_result),
        .ALU_Zero(ALU_Zero),
        .ctrl_EX(ctrl_EX),
        .pc_MEM(pc_MEM),
        .rs2_MEM(rs2_MEM),
        .imm_MEM(imm_MEM),
        .ALU_result_MEM(ALU_result_MEM),
        .ALU_Zero_MEM(ALU_Zero_MEM),
        .ctrl_MEM(ctrl_MEM)
    );

    // Stage 4: MEM
    logic [31:0] mem_rdata;

    DataMem DM (
        .clk(clk),
        .rst(rst),
        .dm_addr(ALU_result_MEM),
        .wdata(rs2_MEM),
        .w_en(ctrl_MEM.mem_write),
        .r_en(ctrl_MEM.mem_read),
        .rdata(mem_rdata)
    );

    // MEM/WB register
    logic [31:0] ALU_result_WB, rdata_WB, pc_WB;
    

    MEM_WB stage4 (
        .clk(clk),
        .rst(rst),
        .ALU_result_MEM(ALU_result_MEM),
        .rdata(mem_rdata),
        .pc_MEM(pc_MEM),
        .ctrl_MEM(ctrl_MEM),
        .ALU_result_WB(ALU_result_WB),
        .rdata_WB(rdata_WB),
        .pc_WB(pc_WB),
        .ctrl_WB(ctrl_WB)
    );

    // Stage 5: WB
    ResultMux RM (
        .result_src(ctrl_WB.result_src),
        .ALU_result(ALU_result_WB),
        .mem_rdata(rdata_WB),
        .pc_plus4(pc_WB + 32'd4),
        .wr_data(wr_data)
    );
    ForwardingUnit FU (
        .id_ex_rs1addr(rs1addr_EX),
        .id_ex_rs2addr(rs2addr_EX),
        .ex_mem_rdaddr(ctrl_MEM.rdaddr),
        .ex_mem_reg_write(ctrl_MEM.reg_write),
        .mem_wb_rdaddr(ctrl_WB.rdaddr),
        .mem_wb_reg_write(ctrl_WB.reg_write),
        .forwardA_sel(forwardA_sel),
        .forwardB_sel(forwardB_sel)
    );
    // Monitor for testbench
    // sythesis translate_off
    logic [31:0] instruction_counter, cycle_counter;
    logic [31:0] stall_counter, flush_counter, branch_counter, forward_counter;

    logic instruction_retired;
    logic forward_used;

    assign instruction_retired =
        ctrl_WB.reg_write ||
        ctrl_WB.mem_write ||
        ctrl_WB.branch ||
        ctrl_WB.jump ||
        ctrl_WB.jalr;

    assign forward_used =
        (forwardA_sel != 2'b00) ||
        (forwardB_sel != 2'b00);

    Monitor monitor (
        .clk(clk),
        .rst(rst),
        .instruction_retired(instruction_retired),
        .stall(stall),
        .flush(pc_src),
        .forward(forward_used),

        .instruction_counter(instruction_counter),
        .cycle_counter(cycle_counter),
        .stall_counter(stall_counter),
        .flush_counter(flush_counter),
        .forward_counter(forward_counter)
    );
    // synthesis translate_on
endmodule
