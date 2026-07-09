.section .text
.globl _start

_start:
    # fence should behave as a no-op in this simple single-core model.
    addi x1, x0, 1024
    addi x2, x0, 99
    sw   x2, 0(x1)
    fence
    lw   x3, 0(x1)
    addi x4, x0, 99
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
