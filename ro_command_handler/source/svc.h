#pragma once

Result svc_acceptSession(Handle* session, Handle port);
Result svc_replyAndReceive(s32* index, Handle* handles, s32 handleCount, Handle replyTarget);

Result svc_controlProcessMemory(Handle KProcess, unsigned int Addr0, unsigned int Addr1, unsigned int Size, unsigned int Type, unsigned int Permissions);
Result svc_mapProcessMemory(Handle KProcess, unsigned int StartAddr, unsigned int EndAddr);
Result svc_unmapProcessMemory(Handle KProcess, unsigned int StartAddr, unsigned int EndAddr);
