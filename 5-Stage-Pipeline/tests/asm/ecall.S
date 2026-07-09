.section .text
.globl _start

_start:
    # The testbench should halt when ecall reaches decode.
    ecall
    jal  x0, fail

fail:
    addi x31, x0, 2
    lui  x30, 0xF
    sw   x31,  0(x30)
    jal  x0, fail
