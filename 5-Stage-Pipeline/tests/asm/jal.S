.section .text
.globl _start

_start:
    # jal
    jal  x1, target
    jal  x0, fail

target:
    addi x2, x0, 1
    addi x3, x0, 1
    bne  x2, x3, fail

pass:
    addi x5, x0, 1
    sw   x5, 0(x0)
    jal  x0, pass

fail:
    addi x5, x0, 2
    sw   x5, 0(x0)
    jal  x0, fail