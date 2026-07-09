module RV32I_SoC(
    input logic clk,
    input logic rst,
    input logic [31:0] gpio_in,
    output logic [31:0] gpio_out,
    output logic [31:0] debug_pc,
    output logic [7:0] debug_status
);
    logic [31:0] instruction;
    logic [31:0] mem_rdata;
    logic [31:0] ram_rdata;
    logic [31:0] gpio_rdata;

    logic [31:0] pc;
    logic [31:0] d_addr;
    logic [31:0] d_wdata;
    logic [2:0] d_funct3;
    logic dw_en;
    logic dr_en;

    logic ram_sel;
    logic gpio_sel;
    logic ram_wen;
    logic ram_ren;
    logic gpio_wen;
    logic gpio_ren;
    logic misaligned;
    logic gpio_write_seen;
    logic ram_write_seen;
    logic ram_read_seen;
    logic misaligned_seen;

    assign debug_pc = pc;
    assign debug_status = {
        rst,
        gpio_write_seen,
        ram_write_seen,
        ram_read_seen,
        gpio_sel,
        ram_sel,
        misaligned_seen,
        gpio_out[0]
    };

    always_ff @(posedge clk) begin
        if (rst) begin
            gpio_write_seen <= 1'b0;
            ram_write_seen <= 1'b0;
            ram_read_seen <= 1'b0;
            misaligned_seen <= 1'b0;
        end else begin
            if (gpio_wen) begin
                gpio_write_seen <= 1'b1;
            end
            if (ram_wen) begin
                ram_write_seen <= 1'b1;
            end
            if (ram_ren) begin
                ram_read_seen <= 1'b1;
            end
            if (misaligned) begin
                misaligned_seen <= 1'b1;
            end
        end
    end

    RV32I_Pipeline CPU (
        .clk(clk),
        .rst(rst),
        .Instruction_in(instruction),
        .mem_rdata(mem_rdata),
        .pc_out(pc),
        .d_addr(d_addr),
        .d_wdata(d_wdata),
        .d_funct3(d_funct3),
        .dw_en(dw_en),
        .dr_en(dr_en)
    );

    AddressDecoder decoder (
        .addr(d_addr),
        .w_en(dw_en),
        .r_en(dr_en),
        .ram_sel(ram_sel),
        .gpio_sel(gpio_sel),
        .ram_wen(ram_wen),
        .ram_ren(ram_ren),
        .gpio_wen(gpio_wen),
        .gpio_ren(gpio_ren)
    );

    UnifiedRam RAM (
        .clk(clk),
        .pc(pc),
        .instruction(instruction),
        .d_addr(d_addr),
        .d_wdata(d_wdata),
        .d_funct3(d_funct3),
        .dw_en(ram_wen),
        .dr_en(ram_ren),
        .d_rdata(ram_rdata),
        .misaligned(misaligned)
    );

    GPIO gpio (
        .clk(clk),
        .rst(rst),
        .wen(gpio_wen),
        .ren(gpio_ren),
        .addr(d_addr),
        .wdata(d_wdata),
        .gpio_in(gpio_in),
        .rdata(gpio_rdata),
        .gpio_out(gpio_out)
    );

    always_comb begin
        if (ram_sel) begin
            mem_rdata = ram_rdata;
        end else if (gpio_sel) begin
            mem_rdata = gpio_rdata;
        end else begin
            mem_rdata = 32'b0;
        end
    end
endmodule
