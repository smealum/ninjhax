.nds

.include "../build/constants.s"

.Create "spider_code.bin",0x0

NUM_OTHER_HANDLES equ 8

;spider code
.arm

	; ;closeThread text spray
	; ldr r0, =0xEF000009 ; svc 0x09 (ExitThread)
	; ldr r1, =0x00100000
	; ldr r2, =0x00100000+SPIDER_TEXT_LENGTH
	; exitThreadLoop:
	; 	ldr r3, [r1]
	; 	mov r3, r3, lsr #28
	; 	;heuristic to mostly overwrite ARM instructions
	; 	cmp r3, #0xE
	; 	streq r0, [r1]
	; 	add r1, #4
	; 	cmp r1, r2
	; 	blt exitThreadLoop

	; ;wake thread1
	; ldr r1, =SPIDER_PROCSEMAPHORE_ADR
	; ldr r1, [r1]
	; mov r2, #1
	; .word 0xEF000016 ; svc 0x16 (ReleaseSemaphore)

	; ;wake thread2
	; ldr r0, =SPIDER_APTHANDLES_ADR+8
	; ldr r0, [r0]
	; .word 0xEF000018 ; svc 0x18 (SignalEvent)

	; ;wake thread3 and thread4
	; ldr r0, =SPIDER_ADDRESSARBITER_ADR
	; ldr r0, [r0] ; handle
	; ldr r1, =SPIDER_ARBADDRESS_1 ;addr
	; ldr r2, =0x00000000 ; arbitration type
	; ldr r3, =0xFFFFFFFF ; value (-1)
	; ldr r4, =0x00000000 ; nanoseconds
	; ldr r5, =0x00000000 ; nanoseconds
	; .word 0xEF000022 ; svc 0x22 (ArbitrateAddress)

	; ;wake thread7
	; ldr r0, =SPIDER_ADDRESSARBITER_ADR
	; ldr r0, [r0] ; handle
	; ldr r1, =SPIDER_ARBADDRESS_2 ;addr
	; ldr r2, =0x00000000 ; arbitration type
	; ldr r3, =0xFFFFFFFF ; value (-1)
	; ldr r4, =0x00000000 ; nanoseconds
	; ldr r5, =0x00000000 ; nanoseconds
	; .word 0xEF000022 ; svc 0x22 (ArbitrateAddress)

	; ;wake thread8
	; ldr r0, =SPIDER_ADDRESSARBITER_ADR
	; ldr r0, [r0] ; handle
	; ldr r1, =SPIDER_ARBADDRESS_3 ;addr
	; ldr r2, =0x00000000 ; arbitration type
	; ldr r3, =0xFFFFFFFF ; value (-1)
	; ldr r4, =0x00000000 ; nanoseconds
	; ldr r5, =0x00000000 ; nanoseconds
	; .word 0xEF000022 ; svc 0x22 (ArbitrateAddress)

	; ;wake thread10
	; ldr r0, =SPIDER_ADDRESSARBITER_ADR
	; ldr r0, [r0] ; handle
	; ldr r1, =SPIDER_ARBADDRESS_4 ;addr
	; ldr r2, =0x00000000 ; arbitration type
	; ldr r3, =0xFFFFFFFF ; value (-1)
	; ldr r4, =0x00000000 ; nanoseconds
	; ldr r5, =0x00000000 ; nanoseconds
	; .word 0xEF000022 ; svc 0x22 (ArbitrateAddress)

	;sleep for a second
	ldr r0, =0x3B9ACA00
	ldr r1, =0x00000000
	.word 0xEF00000A ; sleep

	; ;unmap memory blocks
	; 	;addr 0x10000000
	; 		ldr r0, =SPIDER_HIDMEMHANDLE_ADR
	; 		ldr r0, [r0] ; handle
	; 		ldr r1, =0x10000000 ; addr

	; 		.word 0xEF000020 ; svc 0x20 (UnmapMemoryBlock)

	; 		;induce crash if there's an error
	; 		cmp r0, #0
	; 		ldrne r1, =0xCAFE0062
	; 		ldrne r1, [r1]

	; 	;addr 0x10002000
	; 		ldr r0, =SPIDER_GSPMEMHANDLE_ADR
	; 		ldr r0, [r0] ; handle
	; 		ldr r1, =0x10002000 ; addr

	; 		.word 0xEF000020 ; svc 0x20 (UnmapMemoryBlock)

	; 		;induce crash if there's an error
	; 		cmp r0, #0
	; 		ldrne r1, =0xCAFE0063
	; 		ldrne r1, [r1]

	; ;bruteforce-close all handles
	; 	;scanning data and .bss sections for handles (and closing them)
	; 	ldr r8, =0x003D1000
	; 	ldr r9, =0x003D1000+0x00017E80+0x00056830
	; 	ldr r10, =0x7FFF
	; 	ldr r11, =SPIDER_GSPHANDLE_ADR
	; 	ldr r11, [r11]
	; 	ldr r12, =SPIDER_ROHANDLE_ADR
	; 	ldr r12, [r12]
	; 	closeHandleLoop1:
	; 		ldr r0, [r8], #4
	; 		cmp r0, r11
	; 		beq endCloseHandleLoop1
	; 		cmp r0, r12
	; 		beq endCloseHandleLoop1
	; 		and r1, r0, r10
	; 		cmp r1, #0x30
	; 		bgt endCloseHandleLoop1
	; 		.word 0xEF000023 ; svc 0x23 (CloseHandle)
	; 		endCloseHandleLoop1:
	; 		cmp r8, r9
	; 		blt closeHandleLoop1

	;hand-closing handles stored on the heap

		; ;stray event
		; ldr r0, =0x09a6c000+0x1BC
		; ldr r0, [r0]
		; .word 0xEF000023 ; svc 0x23 (CloseHandle)

		; ;stray mutex
		; ldr r0, =0x080493f4
		; ldr r0, [r0]
		; .word 0xEF000023 ; svc 0x23 (CloseHandle)

		; ;stray timer
		; ldr r0, =0x0804a9e0
		; ldr r0, [r0]
		; .word 0xEF000023 ; svc 0x23 (CloseHandle)

	; ;free GSP heap
	; 	ldr r0, =0x00000001 ; type (FREE)
	; 	ldr r1, =SPIDER_GSPHEAPSTART ; addr0
	; 	ldr r2, =0x00000000 ; addr1
	; 	ldr r3, =SPIDER_GSPHEAPSIZE ; size
	; 	ldr r4, =0x00000000 ; permissions (RW)

	; 	.word 0xEF000001 ; svc 0x01 (ControlMemory)

	; 	;induce crash if there's an error
	; 	cmp r0, #0
	; 	ldrne r1, =0xCAFE0061
	; 	ldrne r1, [r1]

	;reconnect to ro
		sub sp, #0x20
		;connect back to srv:
			ldr r1, =SPIDER_CROMAPADR+srvString+CRO_SPIDERCODE_OFFSET
			.word 0xEF00002D ; svc 0x2D (ConnectToPort)
			str r1, [sp]

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE00080
			ldrne r1, [r1]
			
		;srv:Initialize
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80
			ldr r0, =0x00010002
			str r0, [r8], #4
			ldr r0, =0x00000020
			str r0, [r8], #4
			ldr r0, [sp]
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0081
			ldrne r1, [r1]

		;srv:GetServiceHandle("fs:USER")
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80
			ldr r0, =0x00050100
			str r0, [r8], #4
			ldr r0, =0x553A7366  ;fs:U
			str r0, [r8], #4
			ldr r0, =0x00524553  ;SER
			str r0, [r8], #4
			ldr r0, =0x00000007 ;strlen
			str r0, [r8], #4
			ldr r0, =0x00000000 ;0x0
			str r0, [r8], #4

			ldr r0, [sp]
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)
			ldr r1, [r8, #-0x8]
			str r1, [sp, #0xC]

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0082
			ldrne r1, [r1]

			ldr r1, =SPIDER_ROHANDLE_ADR
			ldr r1, [r1]
			str r1, [sp, #4]

		;FS:Initialize
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x08010002
			str r0, [r8], #4
			ldr r0, =0x00000020
			str r0, [r8], #4

			ldr r0, [sp, 0xC] ; fs:USER handle
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE007F
			ldrne r1, [r1]

		;send fs:USER handle			
			mov r0, #0 ; r0 : handle index (is modified and returned)
			ldr r1, =SPIDER_CROMAPADR+CRO_SPIDERCODE_OFFSET+fsHandleData ; r1 : service name ptr
			ldr r2, =SPIDER_ROHANDLE_ADR
			ldr r2, [r2] ; r2 : hb handle
			ldr r3, [sp, 0xC] ; fs:USER handle
			bl sendHandle

		;get and send other handles (at this point r0 is already set because of sendHandle)
			mov r4, #0
			ldr r5, =SPIDER_CROMAPADR+CRO_SPIDERCODE_OFFSET+otherHandleData
			otherHandleLoop:
				; r0 : handle index (already set)
				; r1 : service name ptr
				add r1, r5, r4
				; r2 : hb handle
				ldr r2, =SPIDER_ROHANDLE_ADR
				ldr r2, [r2]
				; r3 : srv handle
				ldr r3, [sp]

				bl getAndSendHandle

				add r4, #0xC
				cmp r4, NUM_OTHER_HANDLES*0xC
				blt otherHandleLoop

		;srv:GetServiceHandle("APT:U")
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80
			ldr r0, =0x00050100
			str r0, [r8], #4
			ldr r0, =0x3A545041  ;APT:
			str r0, [r8], #4
			ldr r0, =0x00000055  ;U
			str r0, [r8], #4
			ldr r0, =0x00000005 ;strlen
			str r0, [r8], #4
			ldr r0, =0x00000000 ;0x0
			str r0, [r8], #4

			ldr r0, [sp]
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)
			ldr r1, [r8, #-0x8]
			str r1, [sp, #8]

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0082
			ldrne r1, [r1]

		;APT:JumpToApplication
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x00240044 ;cmd header
			str r0, [r8], #4
			ldr r0, =0x00000000 ;arg size
			str r0, [r8], #4
			ldr r0, =0x00000000 ;val 0x0
			str r0, [r8], #4
			ldr r0, [sp, #4] ;arg handle (ldr:ro)
			str r0, [r8], #4
			ldr r0, =0x00000002 ;(arg size << 14)|2
			str r0, [r8], #4
			ldr r0, =SPIDER_CROMAPADR ;arg buffer addr
			str r0, [r8], #4

			ldr r0, [sp, #8]
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0095
			ldrne r1, [r1]

			;induce crash if there's an error
			mrc p15, 0, r8, c13, c0, 3
			ldr r8, [r8,#0x84]
			cmp r8, #0
			ldrne r1, =0xCAFE0096
			ldrne r1, [r1]

		;close handle (APT:U)
			ldr r0, [sp, #8]
			.word 0xEF000023 ; svc 0x23 (CloseHandle)

		;close handle (csnd:SND)
			ldr r0, [sp, #0x10]

		;close handle (fs:USER)
			ldr r0, [sp, #0xC]
			.word 0xEF000023 ; svc 0x23 (CloseHandle)

		;close handle (ldr:ro)
			ldr r0, [sp, #4]
			.word 0xEF000023 ; svc 0x23 (CloseHandle)

		;close handle (srv:)
			ldr r0, [sp]
			.word 0xEF000023 ; svc 0x23 (CloseHandle)
		add sp, #0x20

	;GSPGPU_ReleaseRight
		mrc p15, 0, r8, c13, c0, 3
		add r8, #0x80
		ldr r0, =0x00170000
		str r0, [r8], #4
		ldr r0, =SPIDER_GSPHANDLE_ADR
		ldr r0, [r0]
		.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

		;induce crash if there's an error
		cmp r0, #0
		ldrne r1, =0xCAFE0021
		ldrne r1, [r1]

	; mov sp, #0x10000000

	ldr r4, =0xDEADCAF2
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!
	str r4, [sp, #-4]!

	; .word 0xEF000003 ; svc 0x03 (ExitProcess)

			inftest:
				;sleep for a second
				ldr r0, =0x3B9ACA00
				ldr r1, =0x00000000
				.word 0xEF00000A ; sleep
				b inftest

	; ldr pc, =0x00100000

	; ldr r4, =0xDEADCAFE
	; ldr r4, [r4]

	; inf2:
	; 	b inf2

	; r0 : handle index (is modified and returned)
	; r1 : service name ptr
	; r2 : hb handle
	; r3 : handle
	sendHandle:
		stmfd sp!, {r4-r8}
			mov r5, r0

			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			; cmd header
			ldr r6, =0x000300C2
			str r6, [r8]
			; index
			str r5, [r8, #0x4]
			; name (part 1)
			ldr r6, [r1]
			str r6, [r8, #0x8]
			; name (part 2)
			ldr r6, [r1, #0x4]
			str r6, [r8, #0xC]
			; value 0
			mov r6, #0
			str r6, [r8, #0x10]
			; handle
			str r3, [r8, #0x14]

			mov r0, r2
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			; crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0083
			ldrne r1, [r1]

			add r5, #1

		mov r0, r5
		ldmfd sp!, {r4-r8}
		bx lr

	; r0 : handle index (is modified and returned)
	; r1 : service name ptr
	; r2 : hb handle
	; r3 : srv handle
	getAndSendHandle:
		stmfd sp!, {r4-r8,lr}
			mov r7, r0

			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			; cmd header
			ldr r6, =0x00050100
			str r6, [r8]
			; name part 1
			ldr r6, [r1]
			str r6, [r8, #0x4]
			; name part 2
			ldr r6, [r1, #4]
			str r6, [r8, #0x8]
			; strlen
			ldr r6, [r1, #8]
			str r6, [r8, #0xC]
			; 0
			mov r6, #0
			str r6, [r8, #0x10]

			mov r0, r3
			stmfd sp!, {r1-r2}
				.word 0xEF000032 ; svc 0x32 (SendSyncRequest)
			ldmfd sp!, {r1-r2}

			; return if there's an error
			cmp r0, #0
			ldreq r0, [r8, #0x4]
			cmpeq r0, #0
			bne getAndSendHandleEnd

			mov r0, r7
			ldr r3, [r8, 0xC]
			bl sendHandle
			mov r7, r0

			ldr r0, [r8, 0xC]
			.word 0xEF000023 ; svc 0x23 (CloseHandle)

		getAndSendHandleEnd:
		mov r0, r7
		ldmfd sp!, {r4-r8,pc}

	.pool

srvString:
	.ascii "srv:"
	.byte 0x00

.align 0x8
fsHandleData:
	.ascii "fs:USER"
	.align 0x8
	.word 0x7 ; strlen

.align 0x8
otherHandleData:
	.ascii "ir:rst"
	.align 0x4 ; be careful to align right for very short service names if any ever come along
	.word 0x6
	.ascii "csnd:SND"
	.align 0x4
	.word 0x8
	.ascii "mvd:STD"
	.align 0x4
	.word 0x7
	.ascii "am:app"
	.align 0x4
	.word 0x6
	.ascii "l2b2:u"
	.align 0x4
	.word 0x6
	.ascii "l2b:u"
	.align 0x4
	.word 0x5
	.ascii "nim:aoc"
	.align 0x4
	.word 0x7
	.ascii "y2r2:u"
	.align 0x4
	.word 0x6


.close
