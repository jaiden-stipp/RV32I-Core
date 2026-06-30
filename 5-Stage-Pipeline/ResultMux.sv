module ResultMux(
	input logic [1:0] result_src,
	input logic [31:0] Q, mem_rdata, pc_plus4,
	output logic [31:0] wr_data
	
);
	always_comb case(result_src)
        2'b00: wr_data = Q;
        2'b01: wr_data = mem_rdata;
        2'b10: wr_data = pc_plus4;
        default: wr_data = 32'b0;
   endcase
endmodule