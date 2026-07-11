module FPGAtop(
    input logic clk,
    input logic SW0,
    output logic LEDR0,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5
);
    logic [31:0] gpio_out;
    logic [31:0] debug_pc;
    logic [7:0] debug_status;
    logic cpu_clk;

    // Slow the 50 MHz board clock to 2 Hz so PC changes are visible.
    ClockDivider #(
        .INPUT_HZ(50_000_000),
        .OUTPUT_HZ(10)
    ) clock_divider (
        .clk_in(clk),
        .clk_out(cpu_clk)
    );

    RV32I_SoC soc (
        .clk(cpu_clk),
        .rst(SW0),
        .gpio_in(32'b0),
        .gpio_out(gpio_out),
        .debug_pc(debug_pc),
        .debug_status(debug_status)
    );

    assign LEDR0 = gpio_out[0];

    SevenSegHex hex0 (.value(debug_pc[3:0]),     .segments(HEX0));
    SevenSegHex hex1 (.value(debug_pc[7:4]),     .segments(HEX1));
    SevenSegHex hex2 (.value(debug_pc[11:8]),    .segments(HEX2));
    SevenSegHex hex3 (.value(debug_pc[15:12]),   .segments(HEX3));
    SevenSegHex hex4 (.value(debug_status[3:0]), .segments(HEX4));
    SevenSegHex hex5 (.value(debug_status[7:4]), .segments(HEX5));
endmodule
