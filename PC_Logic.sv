module PC_Logic(
	input logic clk, rst, jump, jalr, branch, Zero,
	input logic [2:0] funct3,
	input logic [31:0] imm_out, rs1out,
	output logic [31:0] pc
);
	logic [31:0] pc_next, pc_target, pc_plus4;

	always_ff @(posedge clk) 
        if (rst) pc <= 32'b0;
        else pc <= pc_next;
   assign pc_plus4 = pc + 32'd4;
	
	logic pc_src;
   assign pc_target = jalr ? (rs1out + imm_out) : (pc + imm_out);
   assign pc_src = jump | (branch & ((funct3[2] ? ~Zero : Zero) ^ funct3[0]));
   assign pc_next = pc_src ? pc_target : pc_plus4;
endmodule