.section .text
.globl _start

_start:
    # andi
    addi x1, x0, 12
    andi x3, x1, 10
    addi x4, x0, 8
    bne  x3, x4, fail

pass:
    addi x5, x0, 1
    sw   x5, 0(x0)
    jal  x0, pass

fail:
    addi x5, x0, 2
    sw   x5, 0(x0)
    jal  x0, fail