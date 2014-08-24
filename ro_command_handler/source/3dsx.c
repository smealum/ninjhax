#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/svc.h>

#include "../../build/constants.h"

#include "svc.h"
#include "3dsx.h"

//code by fincs

#define RELOCBUFSIZE 512
#define SEC_ASSERT(x) if((x)) return 0x5ECDEAD

typedef struct
{
	void* segPtrs[3]; // code, rodata & data
	u32 segSizes[3];
} _3DSX_LoadInfo;

static inline void* TranslateAddr(u32 addr, _3DSX_LoadInfo* d, u32* offsets)
{
	if (addr < offsets[0])
		return (char*)d->segPtrs[0] + addr;
	if (addr < offsets[1])
		return (char*)d->segPtrs[1] + addr - offsets[0];
	return (char*)d->segPtrs[2] + addr - offsets[1];
}

Result FSFILE_Read(Handle handle, u32 *bytesRead, u64 offset, u32 *buffer, u32 size)
{
	u32 *cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x080200C2;
	cmdbuf[1]=(u32)offset;
	cmdbuf[2]=(u32)(offset>>32);
	cmdbuf[3]=size;
	cmdbuf[4]=(size<<4)|12;
	cmdbuf[5]=(u32)buffer;

	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	if(bytesRead)*bytesRead=cmdbuf[2];

	return cmdbuf[1];
}

u64 fileOffset;

int _fread(void* dst, int size, Handle file)
{
	u32 bytesRead;
	Result ret;
	if((ret=FSFILE_Read(file, &bytesRead, fileOffset, (u32*)dst, size))!=0)return ret;
	fileOffset+=bytesRead;
	return (bytesRead==size)?0:-1;
}

int _fseek(Handle file, u64 offset, int origin)
{
	switch(origin)
	{
		case SEEK_SET:
			fileOffset=offset;
			break;
		case SEEK_CUR:
			fileOffset+=offset;
			break;
	}
	return 0;
}

int Load3DSX(Handle file, Handle process, void* baseAddr)
{
	u32 i, j, k, m;
	u32 END_ADDR = 0x00100000+CN_NEWTOTALPAGES*0x1000;

	SEC_ASSERT(baseAddr >= (void*)0x00100000);
	SEC_ASSERT((((u32) baseAddr) & 0xFFF) == 0); // page alignment

	_fseek(file, 0x0, SEEK_SET);

	_3DSX_Header hdr;
	if (_fread(&hdr, sizeof(hdr), file) != 0)
		return -1;

	if (hdr.magic != _3DSX_MAGIC)
		return -2;

	_3DSX_LoadInfo d;
	u32 offsets[2] = { hdr.codeSegSize, hdr.codeSegSize + hdr.rodataSegSize };
	d.segSizes[0] = (hdr.codeSegSize+0xFFF) &~ 0xFFF;
	SEC_ASSERT(d.segSizes[0] >= hdr.codeSegSize); // int overflow
	d.segSizes[1] = (hdr.rodataSegSize+0xFFF) &~ 0xFFF;
	SEC_ASSERT(d.segSizes[1] >= hdr.rodataSegSize); // int overflow
	d.segSizes[2] = (hdr.dataSegSize+0xFFF) &~ 0xFFF;
	SEC_ASSERT(d.segSizes[2] >= hdr.dataSegSize); // int overflow

	d.segPtrs[0] = baseAddr;
	d.segPtrs[1] = (char*)d.segPtrs[0] + d.segSizes[0];
	SEC_ASSERT(d.segPtrs[1] >= d.segSizes[0]); // int overflow
	d.segPtrs[2] = (char*)d.segPtrs[1] + d.segSizes[1];
	SEC_ASSERT(d.segPtrs[2] >= d.segSizes[1]); // int overflow
	SEC_ASSERT(((u32) d.segPtrs[2]) < END_ADDR); // within user memory

	// Skip header for future compatibility.
	_fseek(file, hdr.headerSize, SEEK_SET);
	
	// Read the relocation headers
	SEC_ASSERT(hdr.dataSegSize >= hdr.bssSize); // int underflow
	u32* relocs = (u32*)((char*)d.segPtrs[2] + hdr.dataSegSize - hdr.bssSize);
	SEC_ASSERT(((u32) relocs) >= d.segPtrs[2]); // int overflow
	SEC_ASSERT(((u32) relocs) < END_ADDR); // within user memory
	u32 nRelocTables = hdr.relocHdrSize/4;
 
	u32 relocsEnd = (u32)(relocs + 3*nRelocTables);
	SEC_ASSERT(relocsEnd >= relocs); // int overflow
	SEC_ASSERT(((u32) relocsEnd) < END_ADDR); // within user memory

	// XXX: Ensure enough RW pages exist at baseAddr to hold a memory block of length "totalSize".
	//    This also checks whether the memory region overflows into IPC data or loader data.
 
	for (i = 0; i < 3; i ++)
		if (_fread(&relocs[i*nRelocTables], nRelocTables*4, file) != 0)
			return -3;
 
	// Read the segments
	if (_fread(d.segPtrs[0], hdr.codeSegSize, file) != 0) return -4;
	if (_fread(d.segPtrs[1], hdr.rodataSegSize, file) != 0) return -5;
	if (_fread(d.segPtrs[2], hdr.dataSegSize - hdr.bssSize, file) != 0) return -6;
 
	// Relocate the segments
	for (i = 0; i < 3; i ++)
	{
		for (j = 0; j < nRelocTables; j ++)
		{
			u32 nRelocs = relocs[i*nRelocTables+j];
			if (j >= 2)
			{
				// We are not using this table - ignore it
				_fseek(file, nRelocs*sizeof(_3DSX_Reloc), SEEK_CUR);
				continue;
			}
 
			static _3DSX_Reloc relocTbl[RELOCBUFSIZE];
 
			u32* pos = (u32*)d.segPtrs[i];
			u32* endPos = pos + (d.segSizes[i]/4);
			SEC_ASSERT(((u32) endPos) < END_ADDR); // within user memory

			while (nRelocs)
			{
				u32 toDo = nRelocs > RELOCBUFSIZE ? RELOCBUFSIZE : nRelocs;
				nRelocs -= toDo;
 
				if (_fread(relocTbl, toDo*sizeof(_3DSX_Reloc), file) != 0)
					return -7;
 
				for (k = 0; k < toDo && pos < endPos; k ++)
				{
					pos += relocTbl[k].skip;
					u32 num_patches = relocTbl[k].patch;
					for (m = 0; m < num_patches && pos < endPos; m ++)
					{
						void* addr = TranslateAddr(*pos, &d, offsets);
						SEC_ASSERT(((u32) pos) < END_ADDR); // within user memory
						switch (j)
						{
							case 0: *pos = (u32)addr; break;
							case 1: *pos = (int)addr - (int)pos; break;
						}
						pos++;
					}
				}
			}
		}
	}
 
	// XXX: Write ARGV structure:
	//    If the start of the data segment begins with "_arg", a devkitARM __argv structure follows immediately after.
	//    Refer to e.g. hbmenu (DS) code to know how to fill it. Allocate ARGV text data at the bottom of the stack.

	//check magic
	if(((u32*)baseAddr)[1]==0x6D72705F)
	{
		// Write service handle table pointer
		// the actual structure has to be filled out by cn_bootloader
		((u32*)baseAddr)[2]=(u32)__service_ptr;
	}

	// Protect memory at d.segPtrs[0] as CODE   (r-x) -- npages = d.segSizes[0] / 0x1000
	for(i=0;i<d.segSizes[0]>>12;i++)svc_controlProcessMemory(process, (u32)d.segPtrs[0]+i*0x1000, 0x0, 0x00001000, MEMOP_PROTECT, 0x5);
	// Protect memory at d.segPtrs[1] as RODATA (r--) -- npages = d.segSizes[1] / 0x1000
	for(i=0;i<d.segSizes[1]>>12;i++)svc_controlProcessMemory(process, (u32)d.segPtrs[1]+i*0x1000, 0x0, 0x00001000, MEMOP_PROTECT, 0x1);
	// Protect memory at d.segPtrs[2] as DATA (rw-) -- npages = d.segSizes[2] / 0x1000
	for(i=0;i<d.segSizes[2]>>12;i++)svc_controlProcessMemory(process, (u32)d.segPtrs[2]+i*0x1000, 0x0, 0x00001000, MEMOP_PROTECT, 0x3);
 
	return 0; // Success.
}
