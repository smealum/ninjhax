.nds

.Create "cn_bootloader.bin",0x0

BOOTLOADERLOC equ 0x000F0000

.orga 0x0
	.arm
		;ro contains the HB handle
		mov r10, r0

		ldr r0, =BOOTLOADERLOC+appCode
		ldr r1, =0x00100000
		ldr r2, =endAppCode-appCode
		mov r3, #0
		copyLoop:
			ldr r4, [r0, r3]
			str r4, [r1, r3]
			add r3, #4
			cmp r3, r2
			blt copyLoop

		ldr r0, =0x0031A000
		mov r1, #0
		ldr r2, =0x0002773C
		mov r3, #0
		clearLoop:
			str r1, [r0, r3]
			add r3, #4
			cmp r3, r2
			blt clearLoop

		;hb:FlushInvalidateCache
			mrc p15, 0, r8, c13, c0, 3
			add r8, #0x80

			ldr r0, =0x00010042
			str r0, [r8], #4
			ldr r0, =0x00100000
			str r0, [r8], #4
			ldr r0, =0x00000000
			str r0, [r8], #4
			ldr r0, =0xFFFF8001 ;current KProcess
			str r0, [r8], #4

			mov r0, r10
			.word 0xEF000032 ; svc 0x32 (SendSyncRequest)

			;induce crash if there's an error
			cmp r0, #0
			ldrne r1, =0xBABE0083
			ldrne r1, [r1]

		mov sp, #0x10000000

		ldr r4, =0xDEADCAFE
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
	.incbin "arm11u.bin"
endAppCode:

.close
