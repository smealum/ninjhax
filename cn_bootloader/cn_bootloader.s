.nds

.Create "cn_bootloader.bin",0x0

BOOTLOADERLOC equ 0x000F0000
SERVICESTRUCTLOC equ 0x000F7000

.orga 0x0
	.arm
		;r0 contains the HB handle
		;r1 contains the file handle
		mov r10, r0
		mov r11, r1

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

		;hb:GetHandle
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x00040040
			str r0, [r8], #4
			ldr r0, =0x00000000
			str r0, [r8], #4

			mov r0, r10
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;r12 is fs:USER handle
			ldr r12, [r8, #4]

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xCAFE0084
			ldrne r1, [r1]

		;fill out service override structure
			ldr r0, =SERVICESTRUCTLOC
			;num
				mov r1, #1
				str r1, [r0], #4
			;service[0]
				ldr r1, =0x553A7366  ;fs:U
				str r1, [r0], #4
				ldr r1, =0x00524553  ;SER
				str r1, [r0], #4
				str r12, [r0], #4

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

.orga 0x3000
appCode:
	; .incbin "arm11u.bin"
endAppCode:

.close
