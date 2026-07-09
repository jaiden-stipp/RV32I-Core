.section .text
.globl _start

_start:
    # Expected to trip UnifiedMem's misaligned halfword store fatal check.
    addi x1, x0, 1024
    addi x2, x0, 123
    sh   x2, 1(x1)
    jal  x0, fail

fail:
    addi x31, x0, 2
    lui  x30, 0xF
    sw   x31,  0(x30)
    jal  x0, fail
