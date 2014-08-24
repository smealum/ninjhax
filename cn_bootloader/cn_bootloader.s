.nds

.Create "cn_bootloader.bin",0x0

BOOTLOADERLOC equ 0x000F0000
HBHANDLELOC equ 0x000F6000
SERVICESTRUCTLOC equ 0x000F7000

.orga 0x0
	.arm
		;r0 contains the HB handle
		;if r0 is 0x0 then load from mem
		cmp r0, #0
		beq notGotHb
			gotHb:
				ldr r10, =HBHANDLELOC
				str r0, [r10]
				mov r10, r0
				mov r9, #0
				b doneHb
			notGotHb:
				ldr r10, =HBHANDLELOC
				ldr r10, [r10]
				mov r9, #1
		doneHb:

		;r1 contains the file handle
		mov r11, r1

		;hb:FlushInvalidateCache
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x00010042
			str r0, [r8], #4
			ldr r0, =0x00100000
			str r0, [r8], #4
			ldr r0, =0x00000000
			str r0, [r8], #4
			ldr r0, =0xFFFF8001
			str r0, [r8], #4

			mov r0, r10
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			mrceq p15, 0, r8, c13, c0, 3
			ldreq r0, [r8, #0x84]
			cmpeq r0, #0
			ldrne r1, =0xBABE0081
			ldrne r1, [r1]

		;hb:Load3dsx
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x00050042
			str r0, [r8], #4
			ldr r0, =0x00100000 ;baseAddr
			str r0, [r8], #4
			ldr r0, =0x00000000
			str r0, [r8], #4
			mov r0, r11 ;fileHandle
			str r0, [r8], #4

			mov r0, r10
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			mrceq p15, 0, r8, c13, c0, 3
			ldreq r0, [r8, #0x84]
			cmpeq r0, #0
			ldrne r1, =0xBABE0083
			ldrne r1, [r1]

		;FSFILE:Close
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x08080000
			str r0, [r8], #4

			mov r0, r11 ;fileHandle
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			mrceq p15, 0, r8, c13, c0, 3
			ldreq r0, [r8, #0x84]
			cmpeq r0, #0
			ldrne r1, =0xBABE0088
			ldrne r1, [r1]

		sub sp, #8
			;hb:GetHandle(fs:USER)
				mrc p15, 0, r8, c13, c0, 3
				add r8, #0x80

				ldr r0, =0x00040040
				str r0, [r8], #4
				ldr r0, =0x00000000 ; index
				str r0, [r8], #4

				mov r0, r10
				.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

				;[sp] is fs:USER handle
				ldr r12, [r8, #4]
				str r12, [sp]

				;induce crash if there's an error
				cmp r0, #0
				mrceq p15, 0, r8, c13, c0, 3
				ldreq r0, [r8, #0x84]
				cmpeq r0, #0
				ldrne r1, =0xBABE0084
				ldrne r1, [r1]

			;hb:GetHandle(csnd:SND)
				mrc p15, 0, r8, c13, c0, 3
				add r8, #0x80

				ldr r0, =0x00040040
				str r0, [r8], #4
				ldr r0, =0x00000001 ; index
				str r0, [r8], #4

				mov r0, r10
				.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

				;[sp, #4] is csnd:SND handle
				ldr r12, [r8, #4]
				str r12, [sp, #4]

				;induce crash if there's an error
				cmp r0, #0
				mrceq p15, 0, r8, c13, c0, 3
				ldreq r0, [r8, #0x84]
				cmpeq r0, #0
				ldrne r1, =0xBABE008C
				ldrne r1, [r1]

			;fill out service override structure
				ldr r0, =SERVICESTRUCTLOC
				;num
					mov r1, #2
					str r1, [r0], #4
				;service[0]
					ldr r1, =0x553A7366  ;fs:U
					str r1, [r0], #4
					ldr r1, =0x00524553  ;SER
					str r1, [r0], #4
					ldr r1, [sp] ; handle
					str r1, [r0], #4
				;service[1]
					ldr r1, =0x646E7363   ;csnd
					str r1, [r0], #4
					ldr r1, =0x444E533A   ;:SND
					str r1, [r0], #4
					ldr r1, [sp, #4] ; handle
					str r1, [r0], #4

		mov sp, #0x10000000

		ldr r4, =0xDEADCAF3
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

		ldr pc, =0x00100000

	.pool

.close
