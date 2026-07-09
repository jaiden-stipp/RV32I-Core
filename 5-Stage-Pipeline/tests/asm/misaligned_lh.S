.section .text
.globl _start

_start:
    # Expected to trip DataMem's misaligned halfword load fatal check.
    addi x1, x0, 128
    addi x2, x0, -1
    sw   x2, 0(x1)
    lh   x3, 1(x1)
    jal  x0, fail

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
