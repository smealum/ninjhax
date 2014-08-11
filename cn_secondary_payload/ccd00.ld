OUTPUT_ARCH(arm)

MEMORY
{
	RAMRO (rx) : ORIGIN = 0x00100000, LENGTH = 0x001DA000
}

SECTIONS
{
	.text : ALIGN(0x1000) {
		build/crt0.o(.init)
		*(.text)
	}
}

