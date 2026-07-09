import pipeline_pkg::*;

module DataMem #(parameter N = 256) (
    input logic clk, rst,
    input logic [31:0] dm_addr,
    input logic [31:0] wdata,
    input logic [2:0] funct3,
    input logic w_en,
    input logic r_en,
    output logic [31:0] rdata
);
    logic [31:0] mem [0:N-1];

    logic [31:0] word;
    logic [1:0] byte_offset;

    assign word = mem[dm_addr[31:2]];
    assign byte_offset = dm_addr[1:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < N; i++) begin
                mem[i] <= 32'b0;
            end
        end else if (w_en) begin
            case (funct3)
                BYTE: begin // sb
                    case (byte_offset)
                        2'd0: mem[dm_addr[31:2]][7:0] <= wdata[7:0];
                        2'd1: mem[dm_addr[31:2]][15:8] <= wdata[7:0];
                        2'd2: mem[dm_addr[31:2]][23:16] <= wdata[7:0];
                        2'd3: mem[dm_addr[31:2]][31:24] <= wdata[7:0];
                    endcase
                end
                HALF: begin // sh
                    case (byte_offset[1])
                        1'b0: mem[dm_addr[31:2]][15:0]  <= wdata[15:0];
                        1'b1: mem[dm_addr[31:2]][31:16] <= wdata[15:0];
                    endcase
                end
                WORD: begin
                    mem[dm_addr[31:2]] <= wdata;
                end
                default: begin
                    mem[dm_addr[31:2]] <= mem[dm_addr[31:2]];
                end
            endcase
        end
    end

    always_comb begin
        rdata = 32'b0;

        if (r_en) begin
            case (funct3)
                BYTE: begin
                    case (byte_offset) 
                        2'd0: rdata = {{24{word[7]}},  word[7:0]};
                        2'd1: rdata = {{24{word[15]}}, word[15:8]};
                        2'd2: rdata = {{24{word[23]}}, word[23:16]};
                        2'd3: rdata = {{24{word[31]}}, word[31:24]};
                    endcase
                end

                HALF: begin
                    if (byte_offset[1]) 
                        rdata = {{16{word[31]}}, word[31:16]};
                    else
                        rdata = {{16{word[15]}}, word[15:0]};
                end

                WORD: begin
                    rdata = word;
                end

                BYTEU: begin
                    case (byte_offset)
                        2'd0: rdata = {24'b0, word[7:0]};
                        2'd1: rdata = {24'b0, word[15:8]};
                        2'd2: rdata = {24'b0, word[23:16]};
                        2'd3: rdata = {24'b0, word[31:24]};
                    endcase
                end

                HALFU: begin
                    if (byte_offset[1]) 
                        rdata = {16'b0, word[31:16]};
                    else
                        rdata = {16'b0, word[15:0]};
                end
                
                default: rdata = 32'b0;
            endcase
        end
        // synthesis translate_off
        if (r_en || w_en) begin
            if ((funct3 == HALF || funct3 == HALFU) && dm_addr[0] != 1'b0) begin
                $fatal("Misaligned halfword access at address %h", dm_addr);
            end

            if (funct3 == WORD && dm_addr[1:0] != 2'b00) begin
                $fatal("Misaligned word access at address %h", dm_addr);
            end
        end
        // synthesis translate_on
    end
    
endmodule