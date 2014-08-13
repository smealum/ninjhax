#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctr/types.h>
#include <ctr/srv.h>
#include <ctr/svc.h>

int* numSessionHandles=(int*)0x140092FC;
Handle* sessionHandles=(Handle*)0x14009B08;

Result svc_controlProcessMemory(Handle KProcess, unsigned int Addr0, unsigned int Addr1, unsigned int Size, unsigned int Type, unsigned int Permissions);
Result svc_mapProcessMemory(Handle KProcess, unsigned int StartAddr, unsigned int EndAddr);
Result svc_unmapProcessMemory(Handle KProcess, unsigned int StartAddr, unsigned int EndAddr);

void HB_FlushInvalidateCache(u32* cmdbuf)
{
	if(!cmdbuf)return;

	Handle processHandle=cmdbuf[3];

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

	u32 memBlockAdr=cmdbuf[1];
	Handle processHandle=cmdbuf[3];
	
	// map block to pre-0x00100000 address
	svc_controlProcessMemory(processHandle, 0x000F0000, memBlockAdr, 0x00008000, MEMOP_MAP, 0x7);

	svc_closeHandle(processHandle);

	//response
	cmdbuf[0]=0x00020040;
	cmdbuf[1]=0x00000000;
}

int _main(Result ret, int currentHandleIndex)
{
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
						switch(cmdbuf[0]>>16)
						{
							case 0x1:
								HB_FlushInvalidateCache(cmdbuf);
								break;
							case 0x2:
								HB_SetupBootloader(cmdbuf);
								break;
						}
					}
					break;
			}
		}
		ret=svc_replyAndReceive(&currentHandleIndex, sessionHandles, *numSessionHandles, sessionHandles[currentHandleIndex]);
	}

	return 0;
}
