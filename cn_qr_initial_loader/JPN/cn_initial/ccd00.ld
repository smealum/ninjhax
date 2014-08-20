OUTPUT_ARCH(arm)

MEMORY
{
	RAMX (rx) : ORIGIN = 0x00180000, LENGTH = 0x1000
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

