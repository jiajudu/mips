
./boot/loader.o:     file format elf32-tradlittlemips


Disassembly of section .text:

00000000 <__start>:
   0:	00 00 00 00 01 00 00 10 00 00 00 00                 ............

0000000c <load_elf>:
   c:	3c10be00 	lui	s0,0xbe00
  10:	3c08464c 	lui	t0,0x464c
  14:	3508457f 	ori	t0,t0,0x457f
  18:	240f0000 	li	t7,0
  1c:	020f7821 	addu	t7,s0,t7
  20:	8de90000 	lw	t1,0(t7)
  24:	8def0004 	lw	t7,4(t7)
  28:	000f7c00 	sll	t7,t7,0x10
  2c:	012f4825 	or	t1,t1,t7
  30:	11090003 	beq	t0,t1,40 <load_elf+0x34>
  34:	00000000 	nop
  38:	10000042 	b	144 <bad>
  3c:	00000000 	nop
  40:	240f0038 	li	t7,56
  44:	020f7821 	addu	t7,s0,t7
  48:	8df10000 	lw	s1,0(t7)
  4c:	8def0004 	lw	t7,4(t7)
  50:	000f7c00 	sll	t7,t7,0x10
  54:	022f8825 	or	s1,s1,t7
  58:	240f0058 	li	t7,88
  5c:	020f7821 	addu	t7,s0,t7
  60:	8df20000 	lw	s2,0(t7)
  64:	8def0004 	lw	t7,4(t7)
  68:	000f7c00 	sll	t7,t7,0x10
  6c:	024f9025 	or	s2,s2,t7
  70:	3252ffff 	andi	s2,s2,0xffff
  74:	240f0030 	li	t7,48
  78:	020f7821 	addu	t7,s0,t7
  7c:	8df30000 	lw	s3,0(t7)
  80:	8def0004 	lw	t7,4(t7)
  84:	000f7c00 	sll	t7,t7,0x10
  88:	026f9825 	or	s3,s3,t7

0000008c <next_sec>:
  8c:	262f0008 	addiu	t7,s1,8
  90:	000f7840 	sll	t7,t7,0x1
  94:	020f7821 	addu	t7,s0,t7
  98:	8df40000 	lw	s4,0(t7)
  9c:	8def0004 	lw	t7,4(t7)
  a0:	000f7c00 	sll	t7,t7,0x10
  a4:	028fa025 	or	s4,s4,t7
  a8:	262f0010 	addiu	t7,s1,16
  ac:	000f7840 	sll	t7,t7,0x1
  b0:	020f7821 	addu	t7,s0,t7
  b4:	8df50000 	lw	s5,0(t7)
  b8:	8def0004 	lw	t7,4(t7)
  bc:	000f7c00 	sll	t7,t7,0x10
  c0:	02afa825 	or	s5,s5,t7
  c4:	262f0004 	addiu	t7,s1,4
  c8:	000f7840 	sll	t7,t7,0x1
  cc:	020f7821 	addu	t7,s0,t7
  d0:	8df60000 	lw	s6,0(t7)
  d4:	8def0004 	lw	t7,4(t7)
  d8:	000f7c00 	sll	t7,t7,0x10
  dc:	02cfb025 	or	s6,s6,t7
  e0:	12800010 	beqz	s4,124 <copy_sec+0x34>
  e4:	00000000 	nop
  e8:	12a0000e 	beqz	s5,124 <copy_sec+0x34>
  ec:	00000000 	nop

000000f0 <copy_sec>:
  f0:	26cf0000 	addiu	t7,s6,0
  f4:	000f7840 	sll	t7,t7,0x1
  f8:	020f7821 	addu	t7,s0,t7
  fc:	8de80000 	lw	t0,0(t7)
 100:	8def0004 	lw	t7,4(t7)
 104:	000f7c00 	sll	t7,t7,0x10
 108:	010f4025 	or	t0,t0,t7
 10c:	ae880000 	sw	t0,0(s4)
 110:	26d60004 	addiu	s6,s6,4
 114:	26940004 	addiu	s4,s4,4
 118:	26b5fffc 	addiu	s5,s5,-4
 11c:	1ea0fff4 	bgtz	s5,f0 <copy_sec>
 120:	00000000 	nop
 124:	26310020 	addiu	s1,s1,32
 128:	2652ffff 	addiu	s2,s2,-1
 12c:	1e40ffd7 	bgtz	s2,8c <next_sec>
 130:	00000000 	nop

00000134 <done>:
 134:	02600008 	jr	s3
 138:	00000000 	nop
 13c:	1000ffff 	b	13c <done+0x8>
 140:	00000000 	nop

00000144 <bad>:
 144:	1000ffff 	b	144 <bad>
 148:	00000000 	nop
