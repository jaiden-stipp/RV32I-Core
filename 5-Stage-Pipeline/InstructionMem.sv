module InstructionMem #(parameter N = 256) (
    input logic [31:0] pc,
    output logic [31:0] Instruction
);
    logic [31:0] mem [0:N-1];
    
    `ifdef MEM_PATH
        initial $readmemh(`MEM_PATH, mem);
    `else
        initial $readmemh("programs/fibonacci.hex", mem);
    `endif

    assign Instruction = mem[pc[31:2]];
endmodule
