module GPIO(
    input logic clk,
    input logic rst,
    input logic wen,
    input logic ren,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    input logic [31:0] gpio_in,
    output logic [31:0] rdata,
    output logic [31:0] gpio_out
);
    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_out <= 32'b0;
        end else if (wen && addr[3:2] == 2'b00) begin
            gpio_out <= wdata;
        end
    end

    always_comb begin
        if (ren) begin
            case (addr[3:2])
                2'b00: rdata = gpio_out;
                2'b01: rdata = gpio_in;
                default: rdata = 32'b0;
            endcase
        end else begin
            rdata = 32'b0;
        end
    end
endmodule
