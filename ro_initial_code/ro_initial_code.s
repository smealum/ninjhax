.nds

ROPROCESSHANDLEADR equ 0x14009600
SPIDERPROCESSHANDLEADR equ 0x14009600

CROMAPADR equ 0x007e5000
CROLOCATION equ 0x083A5000

CODELOCATION equ 0x0E000000
CODELOCATION2 equ 0x0E001000

SPIDER_GSPHANDLE equ 0x003DA72C
RO_HANDLELOC equ 0x003D8FDC

SESSIONHANDLECNT_ADR equ 0x140092FC
SESSIONHANDLES_ADR equ 0x14009B08

SPIDERHANDLE_LOCATION equ 0x0FFFFF34

.Create "ro_initial_code.bin",0x0

;ro code
	.arm
		;allocate some memory for our code
			ldr r0, =0x00000003 ; type (PROTECT)
			ldr r1, =CODELOCATION ; addr0
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00002000 ; size
			ldr r4, =0x00000003 ; permissions (RW)

			.word 0xEF000001 ; svc 0x01 (ControlMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0005
			ldrne r1, [r1]

		;copy code to new memory block
			ldr r0, =CODELOCATION
			ldr r1, =CROMAPADR+roCommandHandler+0x700
			ldr r2, =CROMAPADR+roCommandHandler_end+0x700
			roCodeCopyLoop:
				ldr r3, [r1], #4
				str r3, [r0], #4
				cmp r1, r2
				blt roCodeCopyLoop

		;copy code to new memory block
			ldr r0, =CODELOCATION2
			ldr r1, =CROMAPADR+roCode+0x700
			ldr r2, =CROMAPADR+roCodeEnd+0x700
			roCodeCopyLoop2:
				ldr r3, [r1], #4
				str r3, [r0], #4
				cmp r1, r2
				blt roCodeCopyLoop2

		;make new memory block RWX
			ldr r0, =ROPROCESSHANDLEADR
			ldr r0, [r0]
			ldr r1, =CODELOCATION ; addr0
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00002000 ; size
			ldr r4, =0x00000006 ; type (PROTECT)
			ldr r5, =0x00000007 ; permissions (RWX)
			.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0006
			ldrne r1, [r1]

		;unmap spider mem (mostly for cache reason)
		ldr r0, =SPIDERHANDLE_LOCATION
		ldr r0, [r0]
		mov r1, #0x00100000
		mov r2, #0x0df00000
		mov r6, #0x00000000
		ldr r7, =0xDEADCAFE
		ldr r8, =0xDEADCAFE
		ldr lr, =CODELOCATION2
		stmfd sp!, {r4-r8,lr}
		ldr pc, =0x14002A34

	roCode:
		;r8 = cmdbuf
		mrc p15, 0, r8, c13, c0, 3
		add r8, #0x80

		;make the spider CRO region RWX under spider as well
		ldr r6, =0x216 ; oss.cro size in pages -1

		croProtectLoop:
			ldr r0, =SPIDERHANDLE_LOCATION
			ldr r0, [r0]
			ldr r1, =CROMAPADR ; addr0
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
		ldr r6, =0x26D+0x64+0x18+0x57-1 ; .text size in pages -1

		textProtectLoop:
			ldr r0, =SPIDERHANDLE_LOCATION
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
		; 	ldr r0, =SPIDERHANDLE_LOCATION
		; 	ldr r0, [r0]
		; 	.word 0xEF000023 ; svc 0x23 (CloseHandle)

		;reply to spider
			ldr r1, =0x00040040
			str r1, [r8]
			mov r0, #0
			str r0, [r8, #4]

			ldr r0, =0x0FFFFFD0 ;last index
			ldr r5, [r0]
			ldr r1, =SESSIONHANDLES_ADR
			ldr r2, =SESSIONHANDLECNT_ADR
			ldr r2, [r2]
			ldr r3, =SESSIONHANDLES_ADR
			ldr r3, [r3, r5, lsl 2]

			.word 0xEF00004F ; svc 0x4F (ReplyAndReceive)

			;r1 is the index value
			;value 0 => ?
			;value 1 => session closed
			;value >=2 => got a command


		ldr pc, =CODELOCATION

	.pool
	roCodeEnd:

	roCommandHandler:
		.incbin "../build/ro_command_handler.bin"
	roCommandHandler_end:

.close
