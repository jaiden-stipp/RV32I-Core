.section .text
.globl _start

_start:
    # lb and lh must sign extend into the upper bits.
    addi x1, x0, 1024
    addi x2, x0, -1
    sb   x2, 0(x1)
    lb   x3, 0(x1)
    addi x4, x0, -1
    bne  x3, x4, fail

    addi x2, x0, -2048
    sh   x2, 2(x1)
    lh   x3, 2(x1)
    addi x4, x0, -2048
    bne  x3, x4, fail

pass:
    addi x31, x0, 1
    lui  x30, 0xF
    sw   x31,  0(x30)
    jal  x0, pass

fail:
    addi x31, x0, 2
    lui  x30, 0xF
    sw   x31,  0(x30)
    jal  x0, fail
