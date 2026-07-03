module DataMem #(parameter N = 256) (
    input logic clk, rst,
    input logic [31:0] dm_addr,
    input logic [31:0] wdata,
    input logic w_en,
    input logic r_en,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:N-1];
    integer i;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < N; i++) begin
                mem[i] <= 32'b0;
            end
        end else begin
            if (w_en) mem[dm_addr[31:2]] <= wdata;
        end
    end

    assign rdata = (r_en) ? mem[dm_addr[31:2]] : 32'b0;
    
endmodule