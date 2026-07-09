.section .text
.globl _start

_start:
    # Build dependent ALU chain to force forwarding on both source operands.
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2      # 12
    addi x4, x0, 9
    add  x5, x3, x4      # 21
    sub  x6, x5, x3      # 9 (uses two recently produced regs)
    addi x7, x0, 9
    bne  x6, x7, fail

    add  x8, x5, x6      # 30
    addi x9, x0, 30
    bne  x8, x9, fail

pass:
    addi x5, x0, 1
    lui  x30, 0xF
    sw   x5,  0(x30)
    jal  x0, pass

fail:
    addi x5, x0, 2
    lui  x30, 0xF
    sw   x5,  0(x30)
    jal  x0, fail