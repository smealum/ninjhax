.nds

.open "out_oss.cro",0x0

.orga 0x700
	.incbin "../build/ro_initial_code.bin"

.orga 0x2000
	.incbin "../build/spider_code.bin"

.close
