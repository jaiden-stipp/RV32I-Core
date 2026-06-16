module ALU (
    input logic [31:0] A, B,
    input logic [3:0] ALU_Sel,
    output logic [31:0] Q,
    output logic Zero
);
    typedef enum logic [3:0] {
        ADD = 4'b0000,
        SUB = 4'b0001,
        AND = 4'b0010,
        OR = 4'b0011,
        XOR = 4'b0100,
        SLT = 4'b0101,
        SLTU = 4'b0110,
        SLL = 4'b0111,
        SRL = 4'b1000,
        SRA = 4'b1001,
        PASSB = 4'b1010
    } aluops;
    always_comb begin
        
        case (ALU_Sel) 
            ADD: Q = A + B;
            SUB: Q = A - B;
            AND: Q = A & B;
            OR: Q = A | B;
            XOR: Q = A ^ B;
            SLTU: Q = (A < B);
            SLT: Q = ($signed(A) < $signed(B));
            SLL: Q = A << B[4:0]; 
            SRL: Q = A >> B[4:0]; 
            SRA: Q = $signed(A) >>> B[4:0];
            PASSB: Q = B;
				default: Q = 32'b0;
        endcase
        
    end
	 assign Zero = (Q == 32'b0);
endmodule