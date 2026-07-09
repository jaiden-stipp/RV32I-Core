.section .text
.globl _start

_start:
    # sh/lhu, including zero extension from a halfword with bit 15 set.
    addi x1, x0, 76
    addi x2, x0, -1
    sh   x2, 0(x1)
    lhu  x3, 0(x1)
    lui  x4, 0x10
    addi x4, x4, -1
    bne  x3, x4, fail

    addi x2, x0, 255
    sh   x2, 2(x1)
    lhu  x3, 2(x1)
    addi x4, x0, 255
    bne  x3, x4, fail

pass:
    addi x31, x0, 1
    sw   x31, 0(x0)
    jal  x0, pass

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
