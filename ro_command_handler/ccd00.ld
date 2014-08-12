OUTPUT_ARCH(arm)

MEMORY
{
	RAMRW (rwx) : ORIGIN = 0x0E000000, LENGTH = 0x00002000
}

SECTIONS
{
	.text : ALIGN(0x1000) {
		build/crt0.o(.init)
		*(.text)
		*(.rodata)
	}

	data : ALIGN(0x1000) {
		*(data)
	}
}

