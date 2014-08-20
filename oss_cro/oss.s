.nds

.include "../build/constants.s"

.open "out_oss.cro",0x0

.orga CRO_ROCODE_OFFSET
	.incbin "../build/ro_initial_code.bin"

.orga CRO_SPIDERCODE_OFFSET
	.incbin "../build/spider_code.bin"

.close
