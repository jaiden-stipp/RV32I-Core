.section .text
.globl _start

_start:
    # sh/lh, including sign extension from the stored halfword.
    addi x1, x0, 72
    addi x2, x0, -1
    sh   x2, 2(x1)
    lh   x3, 2(x1)
    addi x4, x0, -1
    bne  x3, x4, fail

    addi x2, x0, 1024
    sh   x2, 0(x1)
    lh   x3, 0(x1)
    addi x4, x0, 1024
    bne  x3, x4, fail

pass:
    addi x31, x0, 1
    sw   x31, 0(x0)
    jal  x0, pass

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
