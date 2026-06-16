module ImmGen(
    input logic [31:0] Instruction,
    input logic [2:0] imm_sel,
    output logic [31:0] imm_out
);
    typedef enum logic [2:0] {
        I = 3'b000,
        S = 3'b001,
        B = 3'b010,
        U = 3'b011,
        J = 3'b100
    } instructiontypes;
    always_comb begin
        case (imm_sel)
            I: imm_out = {{20{Instruction[31]}}, Instruction[31:20]};
            S: imm_out = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
            B: imm_out = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            U: imm_out = {Instruction[31:12], 12'b0};
            J: imm_out = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
            default: imm_out = 32'dx;
        endcase
    end
endmodule