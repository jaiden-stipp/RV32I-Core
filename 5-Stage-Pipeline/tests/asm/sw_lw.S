.section .text
.globl _start

_start:
    # sw/lw
    addi x1, x0, 123
    addi x2, x0, 1024
    sw   x1, 0(x2)
    lw   x3, 0(x2)
    addi x4, x0, 123
    bne  x3, x4, fail

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
