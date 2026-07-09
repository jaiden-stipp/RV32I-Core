.section .text
.globl _start

_start:
    # Expected to trip UnifiedMem's misaligned halfword load fatal check.
    addi x1, x0, 1024
    addi x2, x0, -1
    sw   x2, 0(x1)
    lh   x3, 1(x1)
    jal  x0, fail

fail:
    addi x31, x0, 2
    lui  x30, 0xF
    sw   x31,  0(x30)
    jal  x0, fail
