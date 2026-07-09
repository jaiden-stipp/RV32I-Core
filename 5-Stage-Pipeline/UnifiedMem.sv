import pipeline_pkg::*;

module UnifiedMem #(
    parameter N = 16834
)(
    input logic clk,
    input logic [31:0] pc, d_addr, d_wdata,
    input logic [2:0] d_funct3,
    input logic dw_en, dr_en,
    output logic [31:0] Instruction, d_rdata,
    output logic misaligned
);
    logic [31:0] mem [0:N-1];

    logic [31:0] d_word;
    logic [1:0] byte_offset;

    always_comb begin
        // Instruction port
        if (pc[31:2] < N) Instruction = mem[pc[31:2]];
        else Instruction = 32'h00000013;
        // Memory port
        if (d_addr[31:2] < N) d_word = mem[d_addr[31:2]];
        else d_word = 32'b0;
        byte_offset = d_addr[1:0];

        // Misaligned Memory Access Check
        misaligned = 1'b0;

        if (dr_en || dw_en) begin 
            case (d_funct3)
                HALF, HALFU: misaligned = d_addr[0]; // Checks if alignment is odd
                WORD: misaligned = |d_addr[1:0]; // Checks if there is any byte offset
                default: misaligned = 1'b0;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if(dw_en && !misaligned && d_addr[31:2] < N) begin
            case (d_funct3)
                BYTE: begin // sb
                    case (byte_offset)
                        2'd0: mem[d_addr[31:2]][7:0] <= d_wdata[7:0];
                        2'd1: mem[d_addr[31:2]][15:8] <= d_wdata[7:0];
                        2'd2: mem[d_addr[31:2]][23:16] <= d_wdata[7:0];
                        2'd3: mem[d_addr[31:2]][31:24] <= d_wdata[7:0];
                    endcase
                end
                HALF: begin // sh
                    case (byte_offset[1])
                        1'b0: mem[d_addr[31:2]][15:0]  <= d_wdata[15:0];
                        1'b1: mem[d_addr[31:2]][31:16] <= d_wdata[15:0];
                    endcase
                end
                WORD: begin
                    mem[d_addr[31:2]] <= d_wdata;
                end
                default: begin
                    mem[d_addr[31:2]] <= mem[d_addr[31:2]];
                end
            endcase
        end
    end

    always_comb begin
        d_rdata = 32'b0;

        if (dr_en && !misaligned) begin
            case (d_funct3)
                BYTE: begin
                    case (byte_offset) 
                        2'd0: d_rdata = {{24{d_word[7]}},  d_word[7:0]};
                        2'd1: d_rdata = {{24{d_word[15]}}, d_word[15:8]};
                        2'd2: d_rdata = {{24{d_word[23]}}, d_word[23:16]};
                        2'd3: d_rdata = {{24{d_word[31]}}, d_word[31:24]};
                    endcase
                end

                HALF: begin
                    if (byte_offset[1]) 
                        d_rdata = {{16{d_word[31]}}, d_word[31:16]};
                    else
                        d_rdata = {{16{d_word[15]}}, d_word[15:0]};
                end

                WORD: begin
                    d_rdata = d_word;
                end

                BYTEU: begin
                    case (byte_offset)
                        2'd0: d_rdata = {24'b0, d_word[7:0]};
                        2'd1: d_rdata = {24'b0, d_word[15:8]};
                        2'd2: d_rdata = {24'b0, d_word[23:16]};
                        2'd3: d_rdata = {24'b0, d_word[31:24]};
                    endcase
                end

                HALFU: begin
                    if (byte_offset[1]) 
                        d_rdata = {16'b0, d_word[31:16]};
                    else
                        d_rdata = {16'b0, d_word[15:0]};
                end
                
                default: d_rdata = 32'b0;
            endcase
        end
    end
endmodule
