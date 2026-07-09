.section .text.init
.globl _start

_start:
    la sp, _stack_top

    la t0, _bss_start
    la t1, _bss_end

clear_bss:
    bgeu t0, t1, clear_bss_done

    sw zero, 0(t0)

    addi t0, t0, 4

    jal x0, clear_bss

clear_bss_done:
    call main

halt:
    jal x0, halt