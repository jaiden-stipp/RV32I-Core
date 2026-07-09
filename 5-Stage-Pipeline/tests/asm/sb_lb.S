.section .text
.globl _start

_start:
    # sb/lb, including sign extension from the stored byte.
    addi x1, x0, 64
    addi x2, x0, -128
    sb   x2, 1(x1)
    lb   x3, 1(x1)
    addi x4, x0, -128
    bne  x3, x4, fail

    addi x2, x0, 127
    sb   x2, 2(x1)
    lb   x3, 2(x1)
    addi x4, x0, 127
    bne  x3, x4, fail

pass:
    addi x31, x0, 1
    sw   x31, 0(x0)
    jal  x0, pass

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
