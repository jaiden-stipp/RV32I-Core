module FPGAtop(
    input logic clk,
    input logic rst,
    output logic LEDR0
);
    logic [31:0] gpio_out;

    RV32I_SoC soc (
        .clk(clk),
        .rst(~rst),
        .gpio_in(32'b0),
        .gpio_out(gpio_out)
    );

    assign LEDR0 = gpio_out[0];
endmodule
