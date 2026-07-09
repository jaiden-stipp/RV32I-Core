.section .text
.globl _start

_start:
    # sra
    addi x1, x0, -16
    addi x2, x0, 2
    sra  x3, x1, x2      # -16 >> 2 = -4
    addi x4, x0, -4
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