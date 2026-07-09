.section .text
.globl _start

_start:
    # Seed memory at a data address with value 42.
    addi x10, x0, 1024
    addi x11, x0, 42
    sw   x11, 0(x10)

    # Load-use hazard: addi must wait for lw result.
    lw   x12, 0(x10)
    addi x13, x12, 1
    addi x14, x0, 43
    bne  x13, x14, fail

    # Load-to-branch hazard: branch consumes freshly loaded value.
    lw   x15, 0(x10)
    beq  x15, x11, pass
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
