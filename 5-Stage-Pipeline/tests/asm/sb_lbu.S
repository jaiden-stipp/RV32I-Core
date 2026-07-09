.section .text
.globl _start

_start:
    # sb/lbu, including zero extension from a byte with bit 7 set.
    addi x1, x0, 1024
    addi x2, x0, -1
    sb   x2, 3(x1)
    lbu  x3, 3(x1)
    addi x4, x0, 255
    bne  x3, x4, fail

    addi x2, x0, 18
    sb   x2, 0(x1)
    lbu  x3, 0(x1)
    addi x4, x0, 18
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
