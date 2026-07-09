module AddressDecoder(
    input logic [31:0] addr,
    input logic w_en,
    input logic r_en,
    output logic ram_sel,
    output logic gpio_sel,
    output logic ram_wen,
    output logic ram_ren,
    output logic gpio_wen,
    output logic gpio_ren
);
    assign ram_sel =
        addr < 32'h0001_0000;

    assign gpio_sel =
        (addr >= 32'h1000_0000) &&
        (addr <  32'h1000_0100);

    assign ram_wen =
        w_en && ram_sel;

    assign ram_ren =
        r_en && ram_sel;

    assign gpio_wen =
        w_en && gpio_sel;

    assign gpio_ren =
        r_en && gpio_sel;
endmodule
