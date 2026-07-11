module PC_IF(
    input logic clk, rst,
    input logic [31:0] pc_target,
    input logic pc_src,
    input logic stall,
    output logic [31:0] pc
);
    logic [31:0] pc_plus4, pc_next;
    assign pc_plus4 = pc + 32'd4;

    always_ff @(posedge clk) begin
        if (rst)
        pc <= 32'b0;
    else if (pc_src)
        pc <= pc_target;
    else if (!stall)
        pc <= pc + 32'd4;
    end
        
endmodule
