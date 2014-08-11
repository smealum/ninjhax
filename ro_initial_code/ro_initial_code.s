.nds

ROPROCESSHANDLEADR equ 0x14009600
SPIDERPROCESSHANDLEADR equ 0x14009600

CROMAPADR equ 0x007e5000
CROLOCATION equ 0x083A5000

CODELOCATION equ 0x0E000000

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
			ldr r1, =CROMAPADR+roCode+0x700
			ldr r2, =CROMAPADR+roCodeEnd+0x700
			roCodeCopyLoop:
				ldr r3, [r1], #4
				str r3, [r0], #4
				cmp r1, r2
				blt roCodeCopyLoop

		;make new memory block RWX
			ldr r0, =ROPROCESSHANDLEADR
			ldr r0, [r0]
			ldr r1, =CODELOCATION ; addr0
			ldr r2, =0x00000000 ; addr1
			ldr r3, =0x00001000 ; size
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
		ldr lr, =CODELOCATION
		stmfd sp!, {r4-r8,lr}
		ldr pc, =0x14002A34

		; ldr pc, =CODELOCATION

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
			;value >=2 => got a command (index = sessionNumber-2)

		;session/command handler
		;simplified here; we assume only one process ever connects to us
		;(will write a better version in C, too lazy to do properly in asm)
		;r4 = current index
			sessionLoop:
				mov r4, r1
				ldr r2, =0xc920181a
				cmp r0, r2
				beq closedSessionHandler
				cmp r0, #0
				infrotest: bne infrotest
				cmp r1, #2
				bge commandHandler
				cmp r1, #1
				beq newSessionHandler
				b endSessionLoop

				newSessionHandler:
					ldr r1, =SESSIONHANDLES_ADR+4
					ldr r1, [r1]
					.word 0xEF00004A ; svc 0x4A (AcceptSession)

					ldr r2, =SESSIONHANDLECNT_ADR
					ldr r3, [r2]
					mov r4, r3
					add r3, #1
					str r3, [r2]

					ldr r0, =SESSIONHANDLES_ADR
					str r1, [r0, r4, lsl 2]
					add r4, #1
					mov r1, #0
					str r1, [r0, r4, lsl 2]

					b endSessionLoop

				commandHandler:

					; ldr r10, =0xCAFE0092
					; ldr r10, [r10]

					mrc p15, 0, r8, c13, c0, 3
					add r8, #0x80

					ldr r0, [r8] ;cmd header
					mov r0, r0, lsr #16

					cmp r0, #1
					beq _HB_FlushInvalidateCache
					cmp r0, #2
					beq _HB_SetupBootloader
					b endSessionLoop

					_HB_FlushInvalidateCache:
						;map process mem
							ldr r0, [r8, #0xC]
							mov r1, #0x00100000
							mov r2, #0x00200000
							.word 0xEF000071 ; svc 0x71 (MapProcessMemory)

							cmp r0, #0
							ldrne r10, =0xCAFE0093
							ldrne r10, [r10]

						;unmap process mem
							ldr r0, [r8, #0xC]
							mov r1, #0x00100000
							mov r2, #0x00200000
							.word 0xEF000072 ; svc 0x72 (UnmapProcessMemory)

							cmp r0, #0
							ldrne r10, =0xCAFE0094
							ldrne r10, [r10]

						;close process handle
							ldr r0, [r8, #0xC]
							.word 0xEF000023 ; svc 0x23 (CloseHandle)

						;return values
							ldr r1, =0x00010040
							str r1, [r8]
							mov r0, #0
							str r0, [r8, #4]

						b endSessionLoop

					_HB_SetupBootloader:
						stmfd sp!, {r4}
						;map block to pre-0x00100000 address
							ldr r0, [r8, #0xC]
							ldr r1, =0x000F0000 ; addr0
							ldr r2, [r8, #0x4]
							ldr r3, =0x00008000 ; size
							ldr r4, =0x00000004 ; type (MAP)
							ldr r5, =0x00000007 ; permissions (RWX)

							.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

							cmp r0, #0
							ldrne r10, =0xCAFE00A1
							ldrne r10, [r10]


						;make the ninja's .text, rodata and data regions RWX
						ldr r6, =0x1DA+0x40+0x28+0x1F-1 ; .text size in pages -1

						ninjaTextProtectLoop:
							ldr r0, [r8, #0xC]
							ldr r1, =0x00100000
							add r1, r6, lsl 12
							ldr r2, =0x00000000 ; addr1
							ldr r3, =0x00001000 ; size
							ldr r4, =0x00000006 ; type (PROTECT)
							ldr r5, =0x00000007 ; permissions (RWX)

							.word 0xEF000070 ; svc 0x70 (ControlProcessMemory)

							;induce crash if there's an error
							cmp r0, #0
							ldrne r1, =0xCAFE00A2
							ldrne r1, [r1]

							subs r6, #1
							bge ninjaTextProtectLoop

						;close process handle
							ldr r0, [r8, #0xC]
							.word 0xEF000023 ; svc 0x23 (CloseHandle)

						;return values
							ldr r1, =0x00020040
							str r1, [r8]
							mov r0, #0
							str r0, [r8, #4]

						ldmfd sp!, {r4}
						b endSessionLoop

				closedSessionHandler:
					ldr r0, =SESSIONHANDLES_ADR
					ldr r0, [r0, r4, lsl 2]
					.word 0xEF000023 ; svc 0x23 (CloseHandle)

					ldr r0, =SESSIONHANDLES_ADR
					mov r1, #0
					str r1, [r0, r4, lsl 2]

					ldr r2, =SESSIONHANDLECNT_ADR
					ldr r3, [r2]
					sub r3, #1
					str r3, [r2]

					b endSessionLoop

				endSessionLoop:
					ldr r1, =SESSIONHANDLES_ADR
					ldr r2, =SESSIONHANDLECNT_ADR
					ldr r2, [r2]
					ldr r3, [r1, r4, lsl 2]
					.word 0xEF00004F ; svc 0x4F (ReplyAndReceive)
				b sessionLoop
				
		inf:
			b inf

		; ldr r1, =0xDEADCAFE
		; ldr r1, [r1]

	.pool
	roCodeEnd:

.close
