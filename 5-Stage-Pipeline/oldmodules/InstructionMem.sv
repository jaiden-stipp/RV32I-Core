module InstructionMem #(parameter N = 1024) (
    input logic [31:0] pc,
    output logic [31:0] Instruction
);
    logic [31:0] mem [0:N-1];

    initial begin
        for (int i = 0; i < N; i++)
            mem[i] = 32'h00000013; // addi x0,x0,0
        end

    assign Instruction = mem[pc[31:2]];
endmodule
