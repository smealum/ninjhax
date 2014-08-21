.nds

.include "../../build/constants.s"

.create "spider_hook_rop.bin",0x0

.orga 0x0
	.word 0x002d6a34 ; pop {lr, pc}
		.word SPIDER_INITIALROP_VADR ; lr => sp
	.word 0x002d6a30 ; mov sp, lr | pop {lr, pc}

.Close
