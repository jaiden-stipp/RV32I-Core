import pipeline_pkg::*;

module UnifiedMem #(
    parameter N = 16834
)(
    input logic clk,
    input logic [31:0] pc, d_addr, d_wdata,
    input logic [2:0] d_funct3,
    input logic dw_en, dr_en,
    output logic [31:0] Instruction, d_d_rdata
    output logic misaligned
);
    logic [31:0] mem [0:N-1];

    logic [31:0] d_word;
    logic [1:0] byte_offset;

    always_comb begin
        // Instruction port
        if (pc[31:2] < N) Instruction = mem[pc[31:2]]
        else Instruction = 32'h00000013;

        if (d_addr[31:2] < N) d_word = mem[d_addr[31:2]];
        else d_word = 32'b0;

        misaligned = 1'b0;

        if (r_en || w_en) begin 
            case (d_funct3)
                HALF, HALFU: misaligned = daddr[0]; // Checks if alignment is odd
                WORD: misaligned = |daddr[1:0]; //Checks if there is any byte offset
                default: misaligned = 1'b0;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if(dw_en && !misaligned && d_addr[31:2] < N) begin
            case (d_funct3)
                BYTE: begin
                    case (byte_offset) 
                        2'd0: d_rdata = {{24{word[7]}},  word[7:0]};
                        2'd1: d_rdata = {{24{word[15]}}, word[15:8]};
                        2'd2: d_rdata = {{24{word[23]}}, word[23:16]};
                        2'd3: d_rdata = {{24{word[31]}}, word[31:24]};
                    endcase
                end

                HALF: begin
                    if (byte_offset[1]) 
                        d_rdata = {{16{word[31]}}, word[31:16]};
                    else
                        d_rdata = {{16{word[15]}}, word[15:0]};
                end

                WORD: begin
                    d_rdata = word;
                end

                BYTEU: begin
                    case (byte_offset)
                        2'd0: d_rdata = {24'b0, word[7:0]};
                        2'd1: d_rdata = {24'b0, word[15:8]};
                        2'd2: d_rdata = {24'b0, word[23:16]};
                        2'd3: d_rdata = {24'b0, word[31:24]};
                    endcase
                end

                HALFU: begin
                    if (byte_offset[1]) 
                        d_rdata = {16'b0, word[31:16]};
                    else
                        d_rdata = {16'b0, word[15:0]};
                end
                
                default: d_rdata = 32'b0;
            endcase
        end
    end
endmodule