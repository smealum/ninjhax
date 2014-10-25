#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>

#include "../../build/constants.h"

#include "svc.h"
#include "3dsx.h"

#define NUM_CMD (5)

int* numSessionHandles=(int*)RO_SESSIONHANDLECNT_ADR;
Handle* sessionHandles=(Handle*)RO_SESSIONHANDLES_ADR;

// slot 0 is reserved to FS, the others are FFA
struct {
	u32 name[2];
	Handle handle;
} sentHandleTable[HB_NUM_HANDLES];

typedef void (*cmdHandlerFunction)(u32* cmdbuf);

service_list_t* __service_ptr=(service_list_t*)0x000F7000;

Handle targetProcessHandle;

void HB_FlushInvalidateCache(u32* cmdbuf)
{
	if(!cmdbuf)return;
	if(cmdbuf[0] != 0x10042 || cmdbuf[2] != 0)
	{
		//send error
		cmdbuf[0]=0x00010040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}

	const Handle processHandle=cmdbuf[3];

	Result rc = svc_mapProcessMemory(processHandle, 0x00100000, 0x00200000);
	if(rc == 0)
		svc_unmapProcessMemory(processHandle, 0x00100000, 0x00200000);

	svc_closeHandle(processHandle);

	//response
	cmdbuf[0]=0x00010040;
	cmdbuf[1]=0x00000000;
}

void HB_SetupBootloader(u32* cmdbuf)
{
	if(!cmdbuf)return;
	if(cmdbuf[0] != 0x20042 || cmdbuf[2] != 0)
	{
		//send error
		cmdbuf[0]=0x00020040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}

	const u32 memBlockAdr=cmdbuf[1];
	const Handle processHandle=cmdbuf[3];
	
	// map block to pre-0x00100000 address
	// TODO : make first half RX and second half RW
	svc_controlProcessMemory(processHandle, 0x000F0000, memBlockAdr, 0x00008000, MEMOP_MAP, 0x7);

	// extend .text/rodata/data/bss area...
	int i;
	for(i=0;i<CN_ADDPAGES;i++)
	{
		Result ret=svc_controlProcessMemory(processHandle, 0x00100000+(CN_TOTALPAGES+i)*0x1000, CN_ALLOCPAGES_ADR+0x1000*i, 0x1000, MEMOP_MAP, 0x7);
		if(ret)*(u32*)NULL=ret;
	}

	if(targetProcessHandle)svc_closeHandle(targetProcessHandle);
	targetProcessHandle=processHandle;

	//response
	cmdbuf[0]=0x00020040;
	cmdbuf[1]=0x00000000;
}

void HB_SendHandle(u32* cmdbuf)
{
	if(!cmdbuf)return;
	if(cmdbuf[0] != 0x300C2)	
	{
		//send error
		cmdbuf[0]=0x00030040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}

	const u32 handleIndex=cmdbuf[1];
	const Handle sentHandle=cmdbuf[5];
	if(((cmdbuf[5] != 0) && (cmdbuf[4] != 0)) || handleIndex>=HB_NUM_HANDLES)
	{
		//send error
		cmdbuf[0]=0x00030040;
		cmdbuf[1]=0xFFFFFFFE;
		return;
	}

	if(sentHandleTable[handleIndex].handle)svc_closeHandle(sentHandleTable[handleIndex].handle);
	sentHandleTable[handleIndex].name[0]=cmdbuf[2];
	sentHandleTable[handleIndex].name[1]=cmdbuf[3];
	sentHandleTable[handleIndex].handle=sentHandle;

	//response
	cmdbuf[0]=0x00030040;
	cmdbuf[1]=0x00000000;
}

void HB_GetHandle(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const u32 handleIndex=cmdbuf[1];

	if(handleIndex>=HB_NUM_HANDLES || !sentHandleTable[handleIndex].handle)
	{
		//send error
		cmdbuf[0]=0x00040040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}
	
	//response
	cmdbuf[0]=0x000400C2;
	cmdbuf[1]=0x00000000; // response code : no error
	cmdbuf[2]=sentHandleTable[handleIndex].name[0];
	cmdbuf[3]=sentHandleTable[handleIndex].name[1];
	cmdbuf[4]=0x00000000;
	cmdbuf[5]=sentHandleTable[handleIndex].handle;
}

void HB_Load3dsx(u32* cmdbuf)
{
	if(!cmdbuf)return;
	if(cmdbuf[0] != 0x50042 || cmdbuf[2] != 0)
	{
		//send error
		cmdbuf[0]=0x00050040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}

	const void* baseAddr=(void*)cmdbuf[1];
	const Handle fileHandle=cmdbuf[3];

	Result ret;
	ret=svc_mapProcessMemory(targetProcessHandle, 0x00100000, 0x02000000);
	if(!ret) {
		memset((void*)0x00100000, 0x00, CN_NEWTOTALPAGES*0x1000);
		ret=Load3DSX(fileHandle, targetProcessHandle, (void*)baseAddr);
		svc_unmapProcessMemory(targetProcessHandle, 0x00100000, 0x02000000);
	}

	cmdbuf[0]=0x00050040;
	cmdbuf[1]=ret;
}

cmdHandlerFunction commandHandlers[NUM_CMD]={HB_FlushInvalidateCache, HB_SetupBootloader, HB_SendHandle, HB_GetHandle, HB_Load3dsx};

int _main(Result ret, int currentHandleIndex)
{
	int i; for(i=0;i<HB_NUM_HANDLES;i++)sentHandleTable[i].handle=0;
	targetProcessHandle=0x0;
	while(1)
	{
		if(ret==0xc920181a)
		{
			//close session handle
			svc_closeHandle(sessionHandles[currentHandleIndex]);
			sessionHandles[currentHandleIndex]=sessionHandles[*numSessionHandles];
			sessionHandles[*numSessionHandles]=0x0;
			currentHandleIndex=(*numSessionHandles)--; //we want to have replyTarget=0x0
		}else{
			switch(currentHandleIndex)
			{
				case 0:
					svc_exitProcess();
					break;
				case 1:
					{
						// receiving new session
						svc_acceptSession(&sessionHandles[*numSessionHandles], sessionHandles[currentHandleIndex]);
						currentHandleIndex=(*numSessionHandles)++;
					}
					break;
				default:
					{
						//receiving command from ongoing session
						u32* cmdbuf=getThreadCommandBuffer();
						u8 cmdIndex=cmdbuf[0]>>16;
						if(cmdIndex<=NUM_CMD && cmdIndex>0)commandHandlers[cmdIndex-1](cmdbuf);
					}
					break;
			}
		}
		ret=svc_replyAndReceive((s32*)&currentHandleIndex, sessionHandles, *numSessionHandles, sessionHandles[currentHandleIndex]);
	}

	return 0;
}
