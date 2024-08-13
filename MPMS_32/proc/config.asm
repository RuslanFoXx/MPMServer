;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	SYSTEM: Config + StatusFile
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;       * * *  Set Config Parameters  * * *
;------------------------------------------------
proc GetMethodProcess FindMethod

	mov ESI, TabLibrary

jmpFind@GetMethodProcess:
	lodsd
	or EAX, EAX
	jz jmpEnd@GetMethodProcess

		push ESI
		push [FindMethod]
		push EAX
		call [GetProcAddress]

		pop ESI
		or EAX, EAX
		jz jmpFind@GetMethodProcess

jmpEnd@GetMethodProcess:
	ret
endp
;------------------------------------------------
;       * * *  Set Config Parameters  * * *
;------------------------------------------------
proc SetConfigParameters

local SetNetEvent   LPVOID ?    ;   LPWSAEVENT 
local SetListSocket LPVOID ?    ;   LPSOCKET
;------------------------------------------------
;   * * *  Load DLLibrary
;------------------------------------------------
	mov EDI, TabLibrary

jmpLibraryLoop@SetConfigParameters:
	mov [GetMethod], EDI
	mov ECX, [EDI]
	jECXz jmpInitParams@SetConfigParameters

		inc  ECX
		push ECX
		call [LoadLibrary]

		mov DL, CFG_ERR_Library
		or EAX, EAX
		jz jmpEnd@SetConfigParameters

			mov EDI, [GetMethod]
			stosd

	jmp jmpLibraryLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Init Params
;------------------------------------------------
jmpInitParams@SetConfigParameters:
	mov EDI, ServerConfig.MaxReportStack
	mov ECX, SERVER_CONFIG_DWORD

jmpSetParam@SetConfigParameters:
	mov EAX, [EDI]
	or  EAX, EAX
	jz jmpNextServer@SetConfigParameters

		push ECX
		push ESI

		inc EAX
		mov ESI, EAX
		call StrToWord

		pop ESI
		pop ECX

jmpNextServer@SetConfigParameters:
	mov [SystemReport.ExitCode], ECX

	mov DL, CFG_ERR_SystemParam
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

	stosd
	loop jmpSetParam@SetConfigParameters
;------------------------------------------------
;       * * *  Delta RecvBuffer
;------------------------------------------------
	mov CX,  PORT_DATA_SIZE
	mov EAX, [ServerConfig.MaxBufferSize]
	cmp EAX, [ServerConfig.MaxHeadSize]
	ja jmpSetMaxRecv@SetConfigParameters
		mov [ServerConfig.MaxHeadSize], EAX

jmpSetMaxRecv@SetConfigParameters:
	shr EAX, 12
	inc EAX
	shl EAX, 12
	add ECX, EAX
	sub EAX, [ServerConfig.MaxRecvSize]

	mov [ServerConfig.MaxRecvSize], EAX
	mov [SocketDataSize], ECX
;------------------------------------------------
;       * * *  Set Seconds TimeOut
;------------------------------------------------
	mov EBX, [ServerConfig.MaxTimeOut]
	mov EAX, 1000
	mul EBX
	mov [ServerConfig.MaxTimeOut], EAX
;------------------------------------------------
;       * * *  Set Method
;------------------------------------------------
	xor EAX, EAX
	mov  AL, MAX_ASK_METHOD
	mov  DL, CFG_ERR_Method

	sub EAX, [TotalMethod]
	jz  jmpEnd@SetConfigParameters

	inc EAX
	inc EAX
	mov [TotalMethod], EAX
	mov [SystemReport.ExitCode], EAX
;------------------------------------------------
;       * * *  Set Call Method
;------------------------------------------------
	mov EDI, ErrAskMethod.Directory

jmpHostProcLoop@SetConfigParameters:
	mov EAX, [EDI]
	inc EAX
	stosd
	mov EAX, [EDI]
	inc EAX
	stosd
	mov EAX, [EDI]
	inc EAX
	stosd
	mov [GetMethod], EDI

	mov EAX, [EDI]
	inc EAX
	push EAX
	call GetMethodProcess

	mov DL, CFG_ERR_Method
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

	mov EDI, [GetMethod]
	stosd
	add EDI, 4
	dec [SystemReport.ExitCode]
		jnz jmpHostProcLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Set ListenSocket
;------------------------------------------------
	xor EAX, EAX
	mov  AL, SYS_MSG_Start
	mov [SystemReport.Index], EAX

	mov  AL, MAX_NET_HOST
	mov  DL, CFG_ERR_HostParam
	sub EAX, [TotalHost]
	jz  jmpEnd@SetConfigParameters

	mov [TotalHost], EAX
	inc EAX
	mov [SystemReport.ExitCode], EAX
;------------------------------------------------
;       * * *  Set TotalHosts
;------------------------------------------------
	mov [SystemReport.NetHost], TabNetHost
	mov [SetNetEvent], TabNetEvent
	mov [SetListSocket],   TabListenSocket
	mov [Address.sin_family], AF_INET
;------------------------------------------------
;       * * *  Set IP Address
;------------------------------------------------
jmpListenLoop@SetConfigParameters:
	dec [SystemReport.ExitCode]
	jz jmpSocketPort@SetConfigParameters
;------------------------------------------------
;       * * *  Get Address (inet_addr)
;------------------------------------------------
		mov EBX, [SystemReport.NetHost]
		mov ESI, [EBX+NET_HOST.Address]
		inc ESI
		xor ECX, ECX
		mov EDI, ECX
		mov EBX, ECX
		mov  BL, 10

jmpFindAddr@SetConfigParameters:
		xor EDX, EDX

jmpScanAddr@SetConfigParameters:
		lodsb
		cmp AL, '0'
		jb jmpGetAddr@SetConfigParameters

		cmp AL, '9' 
		ja jmpGetAddr@SetConfigParameters

			sub AL, '0'
			mov CL, AL

			mov EAX, EDX
			mul EBX 
			add EAX, ECX
			mov EDX, EAX
			jmp jmpScanAddr@SetConfigParameters

jmpGetAddr@SetConfigParameters:
		or  EDI, EDX
		ror EDI, 8 
		cmp AL, '.'
			je jmpFindAddr@SetConfigParameters
;------------------------------------------------
;       * * *  Get Port : 20480 = htons( 80 )
;------------------------------------------------
		mov [Address.sin_addr], EDI
		mov [SystemReport.Address], EDI
;       xor EDX, EDX
		mov  DX, INTERNET_PORT
		cmp  AL, ':'
		jne jmpAddrEnd@SetConfigParameters
			xor EDX, EDX

jmpScanPort@SetConfigParameters:
			lodsb
			cmp AL, '0'
			jb jmpGetPort@SetConfigParameters

			cmp AL, '9' 
			ja jmpGetPort@SetConfigParameters

				sub AL, '0'
				mov CL, AL

				mov EAX, EDX
				mul EBX 
				add EAX, ECX
				mov EDX, EAX
				jmp jmpScanPort@SetConfigParameters

jmpGetPort@SetConfigParameters:
			xchg DH, DL

jmpAddrEnd@SetConfigParameters:
		mov [Address.sin_port], DX
;------------------------------------------------
;       * * *  Socket
;------------------------------------------------
		xor EAX, EAX
		inc EAX
		push EAX
		xor EAX, EAX
		push EAX
		push EAX
		push IPPROTO_TCP
		push SOCK_STREAM
		push AF_INET
		call [WSASocket]

		mov  DL, SYS_ERR_Socket
		cmp EAX, INVALID_SOCKET
		je jmpEnd@SetConfigParameters

		mov EDI, [SetListSocket]
		stosd
		mov [SystemReport.Socket],  EAX
		mov [SetListSocket], EDI
;------------------------------------------------
;       * * *  Option SocketPort
;------------------------------------------------
		xor EDX, EDX
		mov  DL, SO_REUSEADDR
		push EDX
		push SetOptionPort
		push EDX
		push SOL_SOCKET
		push EAX
		call [setsockopt]

		mov DL, SYS_ERR_Option
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Binding
;------------------------------------------------
		push SOCKADDR_IN_SIZE
		push Address
		push [SystemReport.Socket]
		call [bind]

		mov DL, SYS_ERR_Binding
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Listen
;------------------------------------------------
		push [ServerConfig.MaxConnections]
		push [SystemReport.Socket]
		call [listen]

		mov DL, SYS_ERR_Listen
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  SocketEvent
;------------------------------------------------
		call [WSACreateEvent]
		mov DL, SYS_ERR_NetEvent
		or EAX, EAX
		jz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  ListenEvent
;------------------------------------------------
		mov EDI, [SetNetEvent]
		stosd
		mov [SetNetEvent], EDI

		push FD_ACCEPT + FD_CLOSE
		push EAX
		push [SystemReport.Socket]
		call [WSAEventSelect]

		mov DL, SYS_ERR_SetEvent
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Get HostProcess
;------------------------------------------------
		mov ESI, [SystemReport.NetHost]
		mov ECX, [ESI+NET_HOST.hProcess]
		jECXz jmpReport@SetConfigParameters

			inc ECX
			push ECX
			call GetMethodProcess

			mov DL, SYS_ERR_HostProc
			or EAX, EAX
			jz jmpEnd@SetConfigParameters

				mov ESI, [SystemReport.NetHost]
				mov [ESI+NET_HOST.hProcess], EAX
;------------------------------------------------
;       * * *  ListenReport
;------------------------------------------------
jmpReport@SetConfigParameters:
;		mov CX, [Address.sin_port]
;		xchg CL, CH
;		mov [SystemReport.Socket], ECX

		mov EAX, SystemReport
		call WriteReport

		add [SystemReport.NetHost], NET_HOST_SIZE
		jmp jmpListenLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Socket Port
;------------------------------------------------
jmpSocketPort@SetConfigParameters:
	xor EAX, EAX
	push EAX
	push EAX
	push EAX
	dec EAX
	push EAX
	call [CreateIoCompletionPort]

	mov DL, SYS_ERR_SocketPort
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		mov [hPortIOSocket], EAX
;------------------------------------------------
;       * * *  Set Report Buffers
;------------------------------------------------
	mov ECX, [ServerConfig.MaxConnections]
	shl ECX, 3
	mov [MaxQueuedProcess], ECX

	mov EAX, [ServerConfig.MaxReportStack]
	xor EBX, EBX
	mov  BL, REPORT_INFO_SIZE
	mul EBX
	mov [TabRouteReport], EAX
	mov [TabQueuedProcess], EAX

	add ECX, EAX
	add ECX, EAX
	add ECX, MAX_SOCKET * 4
;------------------------------------------------
;       * * *  Get ReportBuffers
;------------------------------------------------
	push PAGE_READWRITE
	push MEM_COMMIT
	push ECX
	xor EAX, EAX
	push EAX
	call [VirtualAlloc]

	mov DL, SYS_ERR_TableBuffer
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		mov EDI, GetMemoryBuffer
		stosd
		add EAX, MAX_SOCKET * 4
		stosd
		stosd
		stosd
		mov EDX, [EDI]
		add EAX, EDX
		stosd
		stosd
		stosd
		add EAX, EDX
		stosd
		stosd
		stosd
		add [EDI], EAX
;------------------------------------------------
;       * * *  MethodEvent
;------------------------------------------------
	xor EAX, EAX
	push EAX
	push EAX
	push EAX
	push EAX
	call [CreateEvent]

	mov DL, SYS_ERR_NetEvent
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		mov [RunProcessEvent], EAX
;------------------------------------------------
;       * * *  Thread Process
;------------------------------------------------
	xor EAX, EAX
	push EAX
	push EAX
	push EAX
	push ThreadProcessor
	push EAX
	push EAX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadProcess
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		push EAX
		call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Socket
;------------------------------------------------
	xor EAX, EAX
	push EAX
	push EAX
	push EAX
	push ThreadRouter
	push EAX
	push EAX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadRouter
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		push EAX
		call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Listen
;------------------------------------------------
	xor EAX, EAX
	push EAX
	push EAX
	push EAX
	push ThreadListener
	push EAX
	push EAX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadListen
	or EAX, EAX
		jz jmpEnd@SetConfigParameters

		push EAX
		call [CloseHandle]

	xor EDX, EDX
;------------------------------------------------
;       * * *  End Proc  * * *
;------------------------------------------------
jmpEnd@SetConfigParameters:
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------