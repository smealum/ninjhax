.section ".init"
.arm
.align 4
.global _init
.global _start

_start:
	# blx __libc_init_array
	# swi 0xa
	mov r0, #0
	mov r1, #0
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	mov r11, #0
	mov r12, #0
	mov sp, #0x10000000
	blx _main

_init:
	bx lr
