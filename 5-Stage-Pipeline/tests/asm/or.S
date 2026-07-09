.section .text
.globl _start

_start:
    # or
    addi x1, x0, 12      # 1100
    addi x2, x0, 10      # 1010
    or   x3, x1, x2      # 1110 = 14
    addi x4, x0, 14
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