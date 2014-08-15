OUTPUT_ARCH(arm)

MEMORY
{
	/*RAMRO (rx) : ORIGIN = 0x00100000, LENGTH = 0x001DA000*/
	/*RAMRO (rx) : ORIGIN = 0x002D9000, LENGTH = 0x00001000*/
	RAMRO (rx) : ORIGIN = 0x002D9700, LENGTH = 0x00001000
}

SECTIONS
{
	/*.text : ALIGN(0x1000) {*/
	.text : ALIGN(0x100) {
		build/crt0.o(.init)
		*(.text)
		*(.rodata)
	}
}

