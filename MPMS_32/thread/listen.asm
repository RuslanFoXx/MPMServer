;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	THREAD: Listener + Acceptor
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc ThreadListener ThrControl

local TotalSocket    DWORD ?
local ppTablePort    LPVOID ?
local lpListenIoData LPPORT_IO_DATA ?
;------------------------------------------------
	xor EAX, EAX
	inc EAX
	mov [ThreadListenCtrl], EAX
;------------------------------------------------
;       * * *  Wait Connection
;------------------------------------------------
jmpWaitConnect@Listener:
	mov EDI, ListenReport.NetHost
	xor EAX, EAX
	stosd
	stosd
	stosd

	mov AL, NET_ERR_SetConnect
	mov [ListenReport.TimeLimit], EAX

jmpTimeOut@Listener:
	xor EAX, EAX
	push EAX
	push WAIT_LIST_TIMEOUT
	push EAX
	push TabNetEvent
	push [TotalHost]
	call [WSAWaitForMultipleEvents]

	cmp EAX, WAIT_FAILED
	je jmpListenError@Listener

	mov ECX, [ThreadServerCtrl]
	or  ECX, ECX 
	jz jmpEnd@Listener

	cmp EAX, WAIT_TIMEOUT
	je jmpTimeOut@Listener
;------------------------------------------------
;       * * *  Get Host
;------------------------------------------------
	lea EDI, [EAX*4]
	shl EAX, 4
	add EAX, TabNetHost
	mov [ListenReport.NetHost], EAX
;------------------------------------------------
;       * * *  Get NetEvent
;------------------------------------------------
	push ListenEvent
	push [TabNetEvent+EDI]
	mov EAX, [TabListenSocket+EDI]

	mov [ListenReport.Socket], EAX
	push EAX
	call [WSAEnumNetworkEvents]

	mov DL, NET_ERR_GetConnect
	or EAX, EAX
	jnz jmpReport@Listener
;------------------------------------------------
;       * * *  Ask Socket
;------------------------------------------------
	mov AL, FD_ACCEPT
	test [ListenEvent.lNetworkEvents], EAX
	jz jmpWaitConnect@Listener

		mov EAX, [ListenEvent.iErrorCode + FD_ACCEPT_ERROR]
		or  EAX, EAX
		jnz jmpReportError@Listener
;------------------------------------------------
;       * * *  Accept Connect
;------------------------------------------------
	push EAX
	push EAX
	push SizeOfAddrIn
	push Address
	push [ListenReport.Socket]
	call [WSAAccept]

	mov  DL, NET_ERR_Accept
	cmp EAX, INVALID_SOCKET
	je jmpReport@Listener
;------------------------------------------------
;       * * *  Set Socket + Address
;------------------------------------------------
	mov [ListenReport.Socket], EAX
	mov EAX, [Address.sin_addr]
	mov [ListenReport.Address], EAX
;------------------------------------------------
;       * * *  Set Timeout
;------------------------------------------------
	call [GetTickCount]
	add EAX, [ServerConfig.MaxTimeOut]
	mov [ListenReport.TimeLimit], EAX
;------------------------------------------------
;       * * *  Memory Port Buffer
;------------------------------------------------
	push PAGE_READWRITE
	push MEM_COMMIT
	push [SocketDataSize]
	xor EAX, EAX
	push EAX
	call [VirtualAlloc]

	mov DL, NET_ERR_SocketMemory
	or EAX, EAX
	jz jmpReport@Listener
;------------------------------------------------
;       * * *  Find Free Socket
;------------------------------------------------
		mov [lpListenIoData], EAX

		mov EDI, [TabSocketIoData]
		mov ECX, MAX_SOCKET
		mov  DL, NET_ERR_FindSocket
		xor EAX, EAX
		repnz scasd
		jnz jmpReport@Listener

			mov [TotalSocket], ECX
			lea EBX, [EDI-4]
			mov [ppTablePort], EBX
			mov [ListenReport.TablePort], EBX
;------------------------------------------------
;       * * *  Create Port
;------------------------------------------------
			push EAX
			push EAX
			push [hPortIOSocket]
			push [ListenReport.Socket]
			call [CreateIoCompletionPort]

			mov DL, NET_ERR_PortSocket
			or EAX, EAX
			jz jmpReport@Listener
;------------------------------------------------
;       * * *  Set SocketPort + Buffer
;------------------------------------------------
	mov EBX, [lpListenIoData]
	lea EDI, [EBX+PORT_IO_DATA.TimeLimit]
	mov ESI, ListenReport.TimeLimit
	xor ECX, ECX
	mov  CL, ACCEPT_HEADER_COUNT
	rep movsd

	mov EDI, [ListenReport.TablePort]
	mov [EDI], EBX
	mov ESI, EBX
	mov [ESI+PORT_IO_DATA.Method], ErrAskMethod
;------------------------------------------------
;       * * *  Route Connection
;------------------------------------------------
	mov EDI, [ListenReport.NetHost]
	mov EBX, [EDI+NET_HOST.hProcess]
	or  EBX, EBX
	jnz jmpSending@Listener
;------------------------------------------------
;       * * *  Receiving Accept
;------------------------------------------------
	lea EAX, [ESI+PORT_IO_DATA.Buffer]
	mov [ESI+PORT_IO_DATA.WSABuffer.buf], EAX

	mov EAX, [ServerConfig.MaxHeadSize]
	mov [ESI+PORT_IO_DATA.WSABuffer.len], EAX

	push ECX
	push ESI
	push TransFlag
	push TransBytes
	inc ECX
	push ECX
	lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
	push EAX
	push [ListenReport.Socket]
	call [WSARecv]

	or EAX, EAX
	jz jmpConnected@Listener

		call [WSAGetLastError]
		cmp EAX, ERROR_IO_PENDING
		je jmpConnected@Listener

	mov DL,  NET_ERR_ListRecv
	jmp jmpReport@Listener
;------------------------------------------------
;       * * *  Sending
;------------------------------------------------
jmpSending@Listener:
	push ESI
	call EBX

	mov ESI, [lpListenIoData]
	mov [ESI+PORT_IO_DATA.ExitCode], EAX
	mov [ESI+PORT_IO_DATA.Method], ErrAskMethod

	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	mov EAX, [ServerConfig.MaxSendSize]
	cmp EAX, ECX
	jb jmpSizeSend@Listener
		mov EAX, ECX

 jmpSizeSend@Listener:
	mov [ESI+PORT_IO_DATA.WSABuffer.len], EAX
	xor EAX, EAX
	push EAX
	push ESI
	push EAX
	push TransBytes
	inc EAX
	push EAX 
	lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
	push EAX
	push [ListenReport.Socket]
	call [WSASend]

	or EAX, EAX
	jz jmpConnected@Listener

		call [WSAGetLastError]
		mov  DL, NET_ERR_ListSend
		cmp EAX, ERROR_IO_PENDING
		jne jmpReport@Listener
;------------------------------------------------
;       * * *  Post ListReport
;------------------------------------------------
jmpConnected@Listener:
	mov DL, SRV_MSG_Connected

jmpReport@Listener:
	mov  [ListenReport.TimeLimit], EDX
	call [WSAGetLastError]
;------------------------------------------------
;       * * *  Post ListenError
;------------------------------------------------
jmpReportError@Listener:
	mov [ListenReport.TablePort], EAX

	mov EDI, [SetListenReport]
	lea EDX, [EDI+REPORT_INFO_SIZE]
	cmp EDX, [MaxListenReport]
	jb jmpSetReport@Listener
		mov EDX, [TabListenReport]
;------------------------------------------------
;       * * *  Create Report
;------------------------------------------------
jmpSetReport@Listener:
	cmp EDX, [GetListenReport]
	je jmpError@Listener
		mov ESI, ListenReport
		xor ECX, ECX
		mov CL,  ACCEPT_HEADER_REPORT
		rep movsd
		mov [SetListenReport], EDX
;------------------------------------------------
;       * * *  Error ListReport
;------------------------------------------------
jmpError@Listener:
	mov EAX, [ListenReport.TimeLimit]
	cmp  AL, NET_ERR_WaitConnect
	jae jmpWaitConnect@Listener

	cmp  AL, NET_ERR_SocketMemory
	jbe jmpSocketClose@Listener

	cmp  AL, NET_ERR_PortSocket
	jbe jmpMeroryFree@Listener
;------------------------------------------------
;       * * *  Port Free
;------------------------------------------------
	mov EDI, [ppTablePort]
	xor EAX, EAX
	mov [EDI], EAX
;------------------------------------------------
;       * * *  Merory Free
;------------------------------------------------
jmpMeroryFree@Listener:
	push MEM_RELEASE
	xor EAX, EAX
	push EAX
	push [lpListenIoData]
	call [VirtualFree]
;------------------------------------------------
;       * * *  Close Socket
;------------------------------------------------
jmpSocketClose@Listener:
	push [ListenReport.Socket]
	call [closesocket]
	jmp jmpWaitConnect@Listener
;------------------------------------------------
;       * * *  ListenEvent Error
;------------------------------------------------
jmpListenError@Listener:
	call [WSAGetLastError]
	mov  [SystemReport.Error], EAX
	mov  [SystemReport.Index], NET_ERR_WaitConnect
;------------------------------------------------
;       * * *  Close ListenEvent
;------------------------------------------------
jmpEnd@Listener:
	mov ESI, TabNetEvent
	mov ECX, [TotalHost]

jmpFreeEvent@Listener:
	lodsd
	push ECX
	push ESI
	push EAX
	call [WSACloseEvent]
	pop ESI
	pop ECX
	loop jmpFreeEvent@Listener
;------------------------------------------------
;       * * *  Close ListenSocket
;------------------------------------------------
	mov ESI, TabListenSocket
	mov ECX, [TotalHost]

jmpFreeSocket@Listener:
	lodsd
	push ECX
	push ESI
	push EAX
	call [closesocket]
	pop ESI
	pop ECX
	loop jmpFreeSocket@Listener
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
	mov [ThreadListenCtrl], ECX
	push ECX
	call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------