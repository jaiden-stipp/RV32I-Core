import pipeline_pkg::*;

module ALU (
    input logic [31:0] A, B,
    input logic [3:0] ALU_Sel,
    output logic [31:0] Q,
    output logic Zero
);
    always_comb begin
        case (ALU_Sel)
            ADD:  Q = A + B;
            SUB:  Q = A - B;
            AND:  Q = A & B;
            OR:   Q = A | B;
            XOR:  Q = A ^ B;
            SLTU: Q = (A < B);
            SLT:  Q = ($signed(A) < $signed(B));
            SLL:  Q = A << B[4:0];
            SRL:  Q = A >> B[4:0];
            SRA:  Q = $signed(A) >>> B[4:0];
            PASSB: Q = B;
            default: Q = 32'b0;
        endcase
    end

    assign Zero = (Q == 32'b0);
endmodule
