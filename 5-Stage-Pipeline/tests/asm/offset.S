.section .text
.globl _start

_start:
    # Positive and negative load/store offsets.
    addi x1, x0, 1024
    addi x2, x0, 85
    sb   x2, -4(x1)
    lbu  x3, -4(x1)
    addi x4, x0, 85
    bne  x3, x4, fail

    addi x2, x0, -7
    sw   x2, 8(x1)
    lw   x3, 8(x1)
    bne  x3, x2, fail

    addi x2, x0, 1234
    sh   x2, -2(x1)
    lh   x3, -2(x1)
    addi x4, x0, 1234
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
