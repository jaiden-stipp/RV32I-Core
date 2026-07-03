.section .text
.globl _start

_start:
    # xori
    addi x1, x0, 12
    xori x3, x1, 10
    addi x4, x0, 6
    bne  x3, x4, fail

pass:
    addi x5, x0, 1
    sw   x5, 0(x0)
    jal  x0, pass

fail:
    addi x5, x0, 2
    sw   x5, 0(x0)
    jal  x0, fail