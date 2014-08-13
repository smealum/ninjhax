.arm

.align 4

.global svc_controlProcessMemory
.type svc_controlProcessMemory, %function
svc_controlProcessMemory:
	stmfd sp!, {r4, r5}
	ldr r4, [sp, #0x8]
	ldr r5, [sp, #0xC]
	svc 0x70
	ldmfd sp!, {r4, r5}
	bx lr

.global svc_mapProcessMemory
.type svc_mapProcessMemory, %function
svc_mapProcessMemory:
	svc 0x71
	bx lr

.global svc_unmapProcessMemory
.type svc_unmapProcessMemory, %function
svc_unmapProcessMemory:
	svc 0x72
	bx lr
