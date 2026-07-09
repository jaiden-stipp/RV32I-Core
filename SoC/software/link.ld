ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00010000
}

SECTIONS
{
    .text : {
        KEEP(*(.text.init))
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : {
        *(.data*)
        *(.sdata*)
    } > RAM

    .bss (NOLOAD) : {
        . = ALIGN(4);

        _bss_start = .;

        *(.bss*)
        *(.sbss*)
        *(COMMON)

        . = ALIGN(4);

        _bss_end = .;
    } > RAM

    . = ALIGN(16);

    _end = .;

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
