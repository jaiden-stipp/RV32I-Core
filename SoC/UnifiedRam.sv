module UnifiedRam(
    input logic clk,
    input logic [31:0] pc,
    output logic [31:0] instruction,
    input logic [31:0] d_addr,
    input logic [31:0] d_wdata,
    input logic [2:0] d_funct3,
    input logic dw_en,
    input logic dr_en,
    output logic [31:0] d_rdata,
    output logic misaligned
);
    logic [31:0] ram_rdata;
    logic [31:0] ram_wdata;
    logic [3:0] ram_byteena;

    always_comb begin
        misaligned = 1'b0;
        if (dw_en || dr_en) begin
            case (d_funct3)
                3'b001, 3'b101: misaligned = d_addr[0];       // halfword
                3'b010:         misaligned = |d_addr[1:0];    // word
                default:        misaligned = 1'b0;            // byte
            endcase
        end
    end

    always_comb begin
        case (d_funct3)
            3'b000: ram_byteena = 4'b0001 << d_addr[1:0];          // sb
            3'b001: ram_byteena = d_addr[1] ? 4'b1100 : 4'b0011;   // sh
            default: ram_byteena = 4'b1111;                        // sw/lw
        endcase
    end

    always_comb begin
        case (d_funct3)
            3'b000: ram_wdata = d_wdata << (8 * d_addr[1:0]);       // sb
            3'b001: ram_wdata = d_addr[1] ? {d_wdata[15:0], 16'b0}
                                          : {16'b0, d_wdata[15:0]}; // sh
            default: ram_wdata = d_wdata;                           // sw
        endcase
    end

    always_comb begin
        d_rdata = 32'b0;

        if (dr_en && !misaligned) begin
            case (d_funct3)
                3'b000: begin // lb
                    case (d_addr[1:0])
                        2'd0: d_rdata = {{24{ram_rdata[7]}},  ram_rdata[7:0]};
                        2'd1: d_rdata = {{24{ram_rdata[15]}}, ram_rdata[15:8]};
                        2'd2: d_rdata = {{24{ram_rdata[23]}}, ram_rdata[23:16]};
                        2'd3: d_rdata = {{24{ram_rdata[31]}}, ram_rdata[31:24]};
                    endcase
                end
                3'b001: begin // lh
                    d_rdata = d_addr[1] ? {{16{ram_rdata[31]}}, ram_rdata[31:16]}
                                        : {{16{ram_rdata[15]}}, ram_rdata[15:0]};
                end
                3'b010: begin // lw
                    d_rdata = ram_rdata;
                end
                3'b100: begin // lbu
                    case (d_addr[1:0])
                        2'd0: d_rdata = {24'b0, ram_rdata[7:0]};
                        2'd1: d_rdata = {24'b0, ram_rdata[15:8]};
                        2'd2: d_rdata = {24'b0, ram_rdata[23:16]};
                        2'd3: d_rdata = {24'b0, ram_rdata[31:24]};
                    endcase
                end
                3'b101: begin // lhu
                    d_rdata = d_addr[1] ? {16'b0, ram_rdata[31:16]}
                                        : {16'b0, ram_rdata[15:0]};
                end
                default: d_rdata = 32'b0;
            endcase
        end
    end

    UnifiedMem RAM (
        .clock(clk),
        .address_a(pc[15:2]),
        .data_a(32'b0),
        .wren_a(1'b0),
        .rden_a(1'b1),
        .q_a(instruction),
        .address_b(d_addr[15:2]),
        .data_b(ram_wdata),
        .wren_b(dw_en && !misaligned),
        .rden_b(dr_en && !misaligned),
        .byteena_b(ram_byteena),
        .q_b(ram_rdata)
    );
endmodule
