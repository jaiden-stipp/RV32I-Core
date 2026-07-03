.section .text
.globl _start

_start:
    # bne
    addi x1, x0, 5
    addi x2, x0, 6
    bne  x1, x2, pass
    jal  x0, fail

pass:
    addi x5, x0, 1
    sw   x5, 0(x0)
    jal  x0, pass

fail:
    addi x5, x0, 2
    sw   x5, 0(x0)
    jal  x0, fail