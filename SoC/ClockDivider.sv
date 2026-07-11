module ClockDivider #(
    parameter int unsigned INPUT_HZ  = 50_000_000,
    parameter int unsigned OUTPUT_HZ = 2
) (
    input  logic clk_in,
    output logic clk_out
);
    localparam int unsigned HALF_PERIOD = INPUT_HZ / (2 * OUTPUT_HZ);
    localparam int unsigned COUNTER_WIDTH = $clog2(HALF_PERIOD);

    logic [COUNTER_WIDTH-1:0] counter;

    // Intel FPGA registers support power-up initialization. Keeping this
    // divider free-running lets the SoC receive clock edges while SW0 is reset.
    initial begin
        counter = '0;
        clk_out = 1'b0;
    end

    always_ff @(posedge clk_in) begin
        if (counter == HALF_PERIOD - 1) begin
            counter <= '0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
