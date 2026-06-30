module RegFile(
    input logic clk,
    input logic [4:0] rs1addr,
    input logic [4:0] rs2addr, 
    input logic [4:0] rdaddr,
    input logic wr_en,
    input logic [31:0] wr_data,
    output logic [31:0] rs1out,
    output logic [31:0] rs2out
);
    logic [31:0] registers [31:0];

    always_comb begin
        rs1out = (rs1addr == 5'd0) ? 32'd0 : registers[rs1addr];
        rs2out = (rs2addr == 5'd0) ? 32'd0 : registers[rs2addr];
    end

    always_ff @(posedge clk) begin
        if (wr_en && rdaddr != 5'd0) registers[rdaddr] <= wr_data;
    end
endmodule

