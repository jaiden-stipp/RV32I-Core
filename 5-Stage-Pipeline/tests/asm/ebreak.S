.section .text
.globl _start

_start:
    # The testbench should halt when ebreak reaches decode.
    ebreak
    jal  x0, fail

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail
