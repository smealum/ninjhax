#pragma once

#include <ctr/types.h>
 
// File layout:
// - File header
// - Code, rodata and data relocation table headers
// - Code segment
// - Rodata segment
// - Loadable (non-BSS) part of the data segment
// - Code relocation table
// - Rodata relocation table
// - Data relocation table
 
// Memory layout before relocations are applied:
// [0..codeSegSize)             -> code segment
// [codeSegSize..rodataSegSize) -> rodata segment
// [rodataSegSize..dataSegSize) -> data segment
 
// Memory layout after relocations are applied: well, however the loader sets it up :)
// The entrypoint is always the start of the code segment.
// The BSS section must be cleared manually by the application.
 
// File header
#define _3DSX_MAGIC 0x58534433 // '3DSX'
typedef struct
{
	u32 magic;
	u16 headerSize, relocHdrSize;
	u32 formatVer;
	u32 flags;
 
	// Sizes of the code, rodata and data segments +
	// size of the BSS section (uninitialized latter half of the data segment)
	u32 codeSegSize, rodataSegSize, dataSegSize, bssSize;
} _3DSX_Header;
 
// Relocation header: all fields (even extra unknown fields) are guaranteed to be relocation counts.
typedef struct
{
	u32 cAbsolute; // # of absolute relocations (that is, fix address to post-relocation memory layout)
	u32 cRelative; // # of cross-segment relative relocations (that is, 32bit signed offsets that need to be patched)
	// more?
 
	// Relocations are written in this order:
	// - Absolute relocs
	// - Relative relocs
} _3DSX_RelocHdr;
 
// Relocation entry: from the current pointer, skip X words and patch Y words
typedef struct
{
	u16 skip, patch;
} _3DSX_Reloc;

//service override stuff
typedef struct {
    u32 num;

    struct {
        char name[8];
        Handle handle;
    } services[];
}service_list_t;

extern service_list_t* __service_ptr;

int Load3DSX(Handle file, Handle process, void* baseAddr, u32 heapAddr);
Result CalcRequiredAllocSizeFor3DSX(Handle file, u32* pages_out);
Result PrepareDeallocateExtraHeap(u32* heapAddrOut, u32* heapSizeOut);
