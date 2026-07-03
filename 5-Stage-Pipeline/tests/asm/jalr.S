.section .text
.globl _start

_start:
    # Load target address into x1
    la   x1, target

    # Jump to target using JALR
    jalr x5, 0(x1)

    # Should never execute this
    jal  x0, fail

target:
    addi x2, x0, 7
    addi x3, x0, 7
    bne  x2, x3, fail

pass:
    addi x10, x0, 1
    sw   x10, 0(x0)
    jal  x0, pass

fail:
    addi x10, x0, 2
    sw   x10, 0(x0)
    jal  x0, fail