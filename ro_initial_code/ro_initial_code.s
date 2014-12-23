.nds

.include "../build/constants.s"

.Create "ro_initial_code.bin",0x0

;ro code
	.arm
		;allocate some memory for our code
			ldr r0, =0x00000003 ; type (COMMIT)
			ldr r1, =RO_CODELOCATION ; addr0
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00003000 ; size
			ldr r4, =0x00000003 ; permissions (RW)

			.word 0xEF000001 ; svc 0x01 (ControlMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0005
			ldrne r1, [r1]

		;copy code to new memory block
			ldr r0, =RO_CODELOCATION
			ldr r1, =SPIDER_CROMAPADR+roCommandHandler+CRO_ROCODE_OFFSET
			ldr r2, =SPIDER_CROMAPADR+roCommandHandler_end+CRO_ROCODE_OFFSET
			roCodeCopyLoop:
				ldr r3, [r1], #4
				str r3, [r0], #4
				cmp r1, r2
				blt roCodeCopyLoop

		;copy code to new memory block
			ldr r0, =RO_CODELOCATION2
			ldr r1, =SPIDER_CROMAPADR+roCode+CRO_ROCODE_OFFSET
			ldr r2, =SPIDER_CROMAPADR+roCodeEnd+CRO_ROCODE_OFFSET
			roCodeCopyLoop2:
				ldr r3, [r1], #4
				str r3, [r0], #4
				cmp r1, r2
				blt roCodeCopyLoop2

		;make new memory block RWX
			ldr r0, =RO_PROCESSHANDLEADR
			ldr r0, [r0]
			ldr r1, =RO_CODELOCATION ; addr0
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00003000 ; size
			ldr r4, =0x00000006 ; type (PROTECT)
			ldr r5, =0x00000007 ; permissions (RWX)
			.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0006
			ldrne r1, [r1]

		;unmap spider mem (mostly for cache reason)
		ldr r0, =RO_SPIDERHANDLE_LOCATION
		ldr r0, [r0]
		mov r1, #0x00100000
		mov r2, #0x0df00000
		mov r6, #0x00000000
		ldr r7, =0xDEADCAFE
		ldr r8, =0xDEADCAFE
		ldr lr, =RO_CODELOCATION2
		stmfd sp!, {r4-r8,lr}
		ldr pc, =RO_UNMAPPROCESSMEM_GADGET

	roCode:
		;r8 = cmdbuf
		mrc p15, 0, r8, c13, c0, 3
		add r8, #0x80

		; ;unmap CRO mirror
		; 	ldr r0, =RO_PROCESSHANDLEADR
		; 	ldr r0, [r0]
		; 	ldr r1, =SPIDER_CROMAPADR ; addr0
		; 	ldr r2, =SPIDER_CROLOCATION ; addr1
		; 	ldr r3, =0x00005000 ; size
		; 	ldr r4, =0x00000005 ; type (UNMAP)
		; 	ldr r5, =0x00000007 ; permissions (RWX)
		; 	.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

		; 	;induce crash if there's an error
		; 	cmp r0, #0
		; 	ldrne r1, =0xCAFE000F
		; 	ldrne r1, [r1]

		;make the spider CRO region RWX under spider as well
		ldr r6, =(CRO_SIZE>>12)-1 ; oss.cro size in pages -1

		croProtectLoop:
			ldr r0, =RO_SPIDERHANDLE_LOCATION
			ldr r0, [r0]
			ldr r1, =SPIDER_CROMAPADR ; addr0
			add r1, r6, lsl 12
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00001000 ; size
			ldr r4, =0x00000006 ; type (PROTECT)
			ldr r5, =0x00000007 ; permissions (RWX)

			.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0000
			ldrne r1, [r1]

			subs r6, #1
			bge croProtectLoop

		;make the spider .text region RWX under spider as well
		ldr r6, =SPIDER_TOTAL_PAGES-1 ; .text size in pages -1

		textProtectLoop:
			ldr r0, =RO_SPIDERHANDLE_LOCATION
			ldr r0, [r0]
			ldr r1, =0x00100000
			add r1, r6, lsl 12
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00001000 ; size
			ldr r4, =0x00000006 ; type (PROTECT)
			ldr r5, =0x00000007 ; permissions (RWX)

			.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0002
			ldrne r1, [r1]

			subs r6, #1
			bge textProtectLoop

		; ;close spider process handle
		; 	ldr r0, =RO_SPIDERHANDLE_LOCATION
		; 	ldr r0, [r0]
		; 	.word 0xEF000023 ; svc 0x23 (CloseHandle)
		
		;reply to spider
			ldr r1, =0x00040040
			str r1, [r8]
			mov r0, #0
			str r0, [r8, #4]

			ldr r0, =0x0FFFFFD0 ;last index
			ldr r5, [r0]
			ldr r1, =RO_SESSIONHANDLES_ADR
			ldr r2, =RO_SESSIONHANDLECNT_ADR
			ldr r2, [r2]
			ldr r3, =RO_SESSIONHANDLES_ADR
			ldr r3, [r3, r5, lsl 2]

			.word 0xEF00004F ; svc 0x4F (ReplyAndReceive)

			;r1 is the index value
			;value 0 => ?
			;value 1 => session closed
			;value >=2 => got a command


		ldr pc, =RO_CODELOCATION

	.pool
	roCodeEnd:

	roCommandHandler:
		.incbin "../build/ro_command_handler.bin"
	roCommandHandler_end:

.close
