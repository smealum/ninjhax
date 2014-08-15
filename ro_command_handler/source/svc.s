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

.global svc_replyAndReceive
.type svc_replyAndReceive, %function
svc_replyAndReceive:
              STR   R0, [SP,#-4]!
              SVC   0x4F
              LDR   R2, [SP]
              STR   R1, [R2]
              ADD   SP, SP, #4
              BX    LR


.global svc_acceptSession
.type svc_acceptSession, %function
svc_acceptSession:
              STR   R0, [SP,#-4]!
              SVC   0x4A
              LDR   R2, [SP]
              STR   R1, [R2]
              ADD   SP, SP, #4
              BX    LR
