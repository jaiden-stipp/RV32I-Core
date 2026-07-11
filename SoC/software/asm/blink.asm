
elf/blink.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00010117          	auipc	sp,0x10
   4:	00010113          	mv	sp,sp
   8:	05000293          	li	t0,80
   c:	05000313          	li	t1,80

00000010 <clear_bss>:
  10:	0062f863          	bgeu	t0,t1,20 <clear_bss_done>
  14:	0002a023          	sw	zero,0(t0)
  18:	00428293          	addi	t0,t0,4
  1c:	ff5ff06f          	j	10 <clear_bss>

00000020 <clear_bss_done>:
  20:	008000ef          	jal	ra,28 <main>

00000024 <halt>:
  24:	0000006f          	j	24 <halt>

00000028 <main>:
  28:	00100793          	li	a5,1
  2c:	10000737          	lui	a4,0x10000
  30:	00f72023          	sw	a5,0(a4) # 10000000 <_stack_top+0xfff0000>
  34:	00f72023          	sw	a5,0(a4)
  38:	00f72023          	sw	a5,0(a4)
  3c:	00f72023          	sw	a5,0(a4)
  40:	00f72023          	sw	a5,0(a4)
  44:	00f72023          	sw	a5,0(a4)
  48:	0017c793          	xori	a5,a5,1
  4c:	fe5ff06f          	j	30 <main+0x8>
