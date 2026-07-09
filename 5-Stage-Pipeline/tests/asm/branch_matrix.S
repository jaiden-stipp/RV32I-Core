.section .text
.globl _start

_start:
    # beq
    addi x1, x0, 5
    addi x2, x0, 5
    beq  x1, x2, beq_ok
    jal  x0, fail

beq_ok:
    # bne
    addi x2, x0, 6
    bne  x1, x2, bne_ok
    jal  x0, fail

bne_ok:
    # Signed comparisons: -1 < 1 and 1 >= -1
    addi x3, x0, -1
    addi x4, x0, 1
    blt  x3, x4, blt_ok
    jal  x0, fail

blt_ok:
    bge  x4, x3, bge_ok
    jal  x0, fail

bge_ok:
    # Unsigned comparisons: 1 < 0xffffffff and 0xffffffff >= 1
    bltu x4, x3, bltu_ok
    jal  x0, fail

bltu_ok:
    bgeu x3, x4, pass
    jal  x0, fail

pass:
    addi x5, x0, 1
    lui  x30, 0xF
    sw   x5,  0(x30)
    jal  x0, pass

fail:
    addi x5, x0, 2
    lui  x30, 0xF
    sw   x5,  0(x30)
    jal  x0, fail