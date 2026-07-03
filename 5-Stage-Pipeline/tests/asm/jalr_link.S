.section .text
.globl _start

_start:
    # Jump via register; x5 must receive address of ret_label.
    la   x1, target
    jalr x5, 0(x1)

ret_label:
    jal  x0, fail

target:
    la   x7, ret_label
    bne  x5, x7, fail

    # Basic sanity check after landing at target.
    addi x8, x0, 1
    addi x9, x0, 1
    bne  x8, x9, fail
    jal  x0, pass

pass:
    addi x5, x0, 1
    sw   x5, 0(x0)
    jal  x0, pass

fail:
    addi x5, x0, 2
    sw   x5, 0(x0)
    jal  x0, fail