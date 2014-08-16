#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>

#include "svc.h"
#include "3dsx.h"

#define NUM_CMD (5)

int* numSessionHandles=(int*)0x140092FC;
Handle* sessionHandles=(Handle*)0x14009B08;

Handle sentHandleTable[8];
typedef void (*cmdHandlerFunction)(u32* cmdbuf);

service_list_t* __service_ptr=(service_list_t*)0x000F7000;

Handle targetProcessHandle;

void HB_FlushInvalidateCache(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const Handle processHandle=cmdbuf[3];

	svc_mapProcessMemory(processHandle, 0x00100000, 0x00200000);
	svc_unmapProcessMemory(processHandle, 0x00100000, 0x00200000);

	svc_closeHandle(processHandle);

	//response
	cmdbuf[0]=0x00010040;
	cmdbuf[1]=0x00000000;
}

void HB_SetupBootloader(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const u32 memBlockAdr=cmdbuf[1];
	const Handle processHandle=cmdbuf[3];
	
	// map block to pre-0x00100000 address
	// TODO : make first half RX and second half RW
	svc_controlProcessMemory(processHandle, 0x000F0000, memBlockAdr, 0x00008000, MEMOP_MAP, 0x7);

	if(targetProcessHandle)svc_closeHandle(targetProcessHandle);
	targetProcessHandle=processHandle;

	//response
	cmdbuf[0]=0x00020040;
	cmdbuf[1]=0x00000000;
}

void HB_SendHandle(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const u32 handleIndex=cmdbuf[1];
	const Handle sentHandle=cmdbuf[3];

	if(handleIndex>=8)
	{
		//response
		cmdbuf[0]=0x00030040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}
	
	if(sentHandleTable[handleIndex])svc_closeHandle(sentHandleTable[handleIndex]);
	sentHandleTable[handleIndex]=sentHandle;

	//response
	cmdbuf[0]=0x00030040;
	cmdbuf[1]=0x00000000;
}

void HB_GetHandle(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const u32 handleIndex=cmdbuf[1];

	if(handleIndex>=8 || !sentHandleTable[handleIndex])
	{
		//response
		cmdbuf[0]=0x00040040;
		cmdbuf[1]=0xFFFFFFFF;
		return;
	}
	
	//response
	cmdbuf[0]=0x00040042;
	cmdbuf[1]=0x00000000;
	cmdbuf[2]=0x00000000;
	cmdbuf[3]=sentHandleTable[handleIndex];
}

void HB_Load3dsx(u32* cmdbuf)
{
	if(!cmdbuf)return;

	const void* baseAddr=(void*)cmdbuf[1];
	const Handle fileHandle=cmdbuf[3];

	Result ret;
	ret=svc_mapProcessMemory(targetProcessHandle, 0x00100000, 0x00200000);
	if(!ret)ret=Load3DSX(fileHandle, targetProcessHandle, (void*)baseAddr);
	if(!ret)ret=svc_unmapProcessMemory(targetProcessHandle, 0x00100000, 0x00200000);

	cmdbuf[0]=0x00050040;
	cmdbuf[1]=ret;
}

cmdHandlerFunction commandHandlers[NUM_CMD]={HB_FlushInvalidateCache, HB_SetupBootloader, HB_SendHandle, HB_GetHandle, HB_Load3dsx};

int _main(Result ret, int currentHandleIndex)
{
	int i; for(i=0;i<8;i++)sentHandleTable[i]=0;
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
					// ???
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
