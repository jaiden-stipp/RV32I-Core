.section .text
.globl _start

_start:
    addi x1, x0, 0
    addi x2, x0, 200

loop:
    addi x1, x1, 1
    addi x3, x1, 1
    addi x4, x3, 1
    addi x5, x4, 1
    addi x6, x5, 1
    addi x7, x6, 1
    addi x8, x7, 1
    addi x9, x8, 1

    bne  x1, x2, loop

check:
    addi x10, x0, 200
    bne  x1, x10, fail

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