module RV32I_Single(
    input clk,
    input rst
);

    typedef enum logic [6:0] {
        R = 7'b0110011,
        I = 7'b0010011,
        L = 7'b0000011, // Load
        S = 7'b0100011, // Store
        B = 7'b1100011, // Branch
        JAL = 7'b1101111, // Jump and Link
        JALR = 7'b1100111, // Jump and Link Register
        LUI = 7'b0110111, // Load Upper Immediate
        AUIPC = 7'b0010111 // Add Upper Immediate to PC
    } opcodes;

    logic [31:0] Instruction, rs1out, rs2out; // Instruction and RegFile Outs
    logic [31:0] pc; // PC Related
    logic [31:0] ALU_A, ALU_B, Q, imm_out;
    logic [31:0] wr_data, mem_rdata;
    logic [6:0] opcode, funct7;
    logic [4:0] rdaddr, rs1addr, rs2addr;
    logic [3:0] ALU_Sel;
    logic [2:0] funct3, imm_sel;
    logic [1:0] result_src;
    logic reg_write, alu_src, mem_write, mem_read, branch, jump, jalr, Zero; // Control Unit out signals

    

    InstructionMem IM (
        .pc(pc),
        .Instruction(Instruction)
    );

    assign opcode = Instruction[6:0];
    assign rdaddr = Instruction[11:7];
    assign funct3 = Instruction[14:12];
    assign rs1addr = Instruction[19:15];
    assign rs2addr = Instruction[24:20];
    assign funct7 = Instruction[31:25];

    ControlUnit CU (
        .opcode(opcode),
        .funct3(funct3),
        .funct7b5(funct7[5]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .imm_sel(imm_sel),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .result_src(result_src),
        .ALU_Sel(ALU_Sel)
    );

    RegFile RF (
        .clk(clk),
        .rs1addr(rs1addr),
        .rs2addr(rs2addr),
        .rdaddr(rdaddr),
        .wr_en(reg_write),
        .wr_data(wr_data),
        .rs1out(rs1out),
        .rs2out(rs2out)
    );

    ImmGen IG (
        .Instruction(Instruction),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    assign ALU_B = alu_src ? imm_out: rs2out;
    assign ALU_A = opcode == AUIPC ? pc:rs1out;

    ALU alu (
        .A(ALU_A),
        .B(ALU_B),
        .ALU_Sel(ALU_Sel),
        .Q(Q),
        .Zero(Zero)
    );
    
    DataMem DM (
        .clk(clk),
        .dm_addr(Q),
        .wdata(rs2out),
        .w_en(mem_write),
        .r_en(mem_read),
        .rdata(mem_rdata)
    );
	 ResultMux RM (
		.result_src(result_src),
		.Q(Q),
		.mem_rdata(mem_rdata),
		.pc_plus4(pc_plus4),
		.wr_data(wr_data)
	 );
    
	 PC_Logic PC (
		.clk(clk),
		.rst(rst),
		.jump(jump),
		.jalr(jalr),
		.branch(branch),
		.Zero(Zero),
		.funct3(funct3),
		.imm_out(imm_out),
		.rs1out(rs1out),
		.pc(pc)
	 );
    
endmodule