.section .text
.globl _start

_start:
    # Expected to trip DataMem's misaligned halfword store fatal check.
    addi x1, x0, 136
    addi x2, x0, 123
    sh   x2, 1(x1)
    jal  x0, fail

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
