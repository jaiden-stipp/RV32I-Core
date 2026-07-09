.section .text
.globl _start

_start:
    # sw/lw regression with two independent aligned words.
    addi x1, x0, 1024
    lui  x2, 0x12345
    addi x2, x2, 0x678
    sw   x2, 0(x1)
    lw   x3, 0(x1)
    bne  x3, x2, fail

    addi x4, x0, -42
    sw   x4, 4(x1)
    lw   x5, 4(x1)
    bne  x5, x4, fail

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
