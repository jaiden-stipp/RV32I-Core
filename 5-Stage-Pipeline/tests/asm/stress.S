.section .text
.globl _start

_start:
    # Forwarding-heavy test
    addi x1, x0, 1
    addi x2, x1, 1
    addi x3, x2, 1
    addi x4, x3, 1
    addi x5, x4, 1
    addi x6, x5, 1
    addi x7, x6, 1
    addi x8, x7, 1

    # x8 should equal 8
    addi x9, x0, 8
    bne  x8, x9, fail

    # Load-use stall test
    addi x10, x0, 100
    addi x11, x0, 42
    sw   x11, 0(x10)
    lw   x12, 0(x10)
    addi x13, x12, 1

    # x13 should equal 43
    addi x14, x0, 43
    bne  x13, x14, fail

    # Branch/flush test
    addi x15, x0, 5
    addi x16, x0, 5
    beq  x15, x16, branch_taken
    jal  x0, fail

branch_taken:
    addi x17, x0, 99
    addi x18, x0, 99
    bne  x17, x18, fail

pass:
    addi x31, x0, 1
    sw   x31, 0(x0)
    jal  x0, pass

fail:
    addi x31, x0, 2
    sw   x31, 0(x0)
    jal  x0, fail