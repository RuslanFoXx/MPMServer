;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	SYSTEM: Set Config Parameters
;	ver.1.75 (x64)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc GetMethodProcess   ;   FindMethod

local FindMethod  PCHAR ?
local TabLibMethod  PCHAR ?
;------------------------------------------------
	xor RAX, RAX
	mov AL,  32
	sub RSP, RAX

	mov [FindMethod], RCX
	mov [TabLibMethod], TabLibrary

jmpFind@GetMethodProcess:
	lodsq
	mov RCX, RAX
	jRCXz jmpEnd@GetMethodProcess

		mov  [TabLibMethod], RSI
		param 2, [FindMethod]
		param 1, RAX
		call [GetProcAddress]

		mov RSI, [TabLibMethod]
		or  RAX, RAX
		jz jmpFind@GetMethodProcess

jmpEnd@GetMethodProcess:
	xor RAX, RAX
	mov AL,  32
	add RSP, RAX
	ret
endp
;------------------------------------------------
;       * * *  Set Config Parameters  * * *
;------------------------------------------------
proc SetConfigParameters

local SetNetEvent   LPVOID ?    ;   LPWSAEVENT 
local SetListSocket LPVOID ?    ;   LPSOCKET
;------------------------------------------------
	xor RAX, RAX
	mov RDI, RAX
	mov AL,  64
	sub RSP, RAX
;------------------------------------------------
;   * * *  Load DLLibrary
;------------------------------------------------
	mov EDI, TabLibrary

jmpLibraryLoop@SetConfigParameters:
	mov [GetMethod], RDI
	mov RCX, [EDI]
	jRCXz jmpInitParams@SetConfigParameters

		inc RCX
		call [LoadLibrary]

		mov DL, CFG_ERR_Library
		or RAX, RAX
		jz jmpEnd@SetConfigParameters

			mov RDI, [GetMethod]
			stosq

	jmp jmpLibraryLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Init Params
;------------------------------------------------
jmpInitParams@SetConfigParameters:
	mov RDI,  ServerConfig.MaxReportStack
	mov R14,  RCX
	mov R14b, SERVER_CONFIG_DWORD

jmpSetParam@SetConfigParameters:
	mov RAX, [RDI]
	or  RAX, RAX
	jz jmpNextServer@SetConfigParameters

		mov R15, RDI
		inc RAX
		mov RSI, RAX
		call StrToWord

jmpNextServer@SetConfigParameters:
	mov [SystemReport.ExitCode], R14d

	mov DL, CFG_ERR_SystemParam
	or RAX, RAX
	jz jmpEnd@SetConfigParameters

	mov RDI, R15
	stosq
	dec R14
	jnz jmpSetParam@SetConfigParameters
;------------------------------------------------
;       * * *  Delta RecvBuffer
;------------------------------------------------
	mov R14w, PORT_DATA_SIZE
	mov RAX, [ServerConfig.MaxBufferSize]
	cmp RAX, [ServerConfig.MaxHeadSize]
	ja jmpSetMaxRecv@SetConfigParameters
		mov [ServerConfig.MaxHeadSize], RAX

jmpSetMaxRecv@SetConfigParameters:
	shr RAX, 12
	inc RAX
	shl RAX, 12
	add R14, RAX
	sub RAX, [ServerConfig.MaxRecvSize]

	mov [ServerConfig.MaxRecvSize], RAX
	mov [SocketDataSize], R14
;------------------------------------------------
;       * * *  Set Seconds TimeOut
;------------------------------------------------
	mov RBX, [ServerConfig.MaxTimeOut]
	xor RAX, RAX
	mov AX, 1000
	mul EBX
	mov [ServerConfig.MaxTimeOut], RAX
;------------------------------------------------
;       * * *  Set Method
;------------------------------------------------
	xor EAX, EAX
	mov  AL, MAX_ASK_METHOD
	mov  DL, CFG_ERR_Method

	sub RAX, [TotalMethod]
	jz  jmpEnd@SetConfigParameters

	inc EAX
	inc EAX
	mov [TotalMethod], RAX
	mov [SystemReport.ExitCode], EAX
;------------------------------------------------
;       * * *  Set Call Method
;------------------------------------------------
	mov RDI, ErrAskMethod.Directory

jmpHostProcLoop@SetConfigParameters:
	mov RAX, [RDI]
	inc RAX

	stosq
	mov RAX, [RDI]
	inc RAX

	stosq
	mov RAX, [RDI]
	inc EAX
	stosq
	mov [GetMethod], RDI

	mov RCX, [RDI]
	inc RCX

	mov RDI, [GetMethod]
	mov RCX, [RDI]
	inc RCX
	call GetMethodProcess
	mov DL, CFG_ERR_Method
	or RAX, RAX
	jz jmpEnd@SetConfigParameters

	mov RDI, [GetMethod]
	stosq
	xor RAX, RAX
	mov  AL, 8
	add RDI, RAX

	dec [SystemReport.ExitCode]
	jnz jmpHostProcLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Set ListenSocket
;------------------------------------------------
	xor RAX, RAX
	mov  AL, SYS_MSG_Start
	mov [SystemReport.Index], EAX

	mov  AL, MAX_NET_HOST
	mov  DL, CFG_ERR_HostParam
	sub RAX, [TotalHost]
	jz jmpEnd@SetConfigParameters

	mov [TotalHost], RAX
	inc EAX
	mov [SystemReport.ExitCode], EAX
;------------------------------------------------
;       * * *  Set TotalHosts
;------------------------------------------------
	mov [SystemReport.NetHost], TabNetHost
	mov [SetNetEvent], TabNetEvent
	mov [SetListSocket], TabListenSocket
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
		mov RBX, [SystemReport.NetHost]
		mov RSI, [RBX+NET_HOST.Address]
		inc RSI
		xor RCX, RCX
		mov RDI, RCX
		mov RBX, RCX
		mov  BL, 10
		mov R8b, '0'
		mov R9b, '9'

jmpFindAddr@SetConfigParameters:
		xor RDX, RDX

jmpScanAddr@SetConfigParameters:
		lodsb
		cmp AL, R8b
		jb jmpGetAddr@SetConfigParameters

		cmp AL, R9b 
		ja jmpGetAddr@SetConfigParameters

			sub AL, R8b
			mov CL, AL
			mov EAX, EDX
			mul RBX 
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
		mov  DX, INTERNET_PORT
		cmp  AL, ':'
		jne jmpAddrEnd@SetConfigParameters
			xor RDX, RDX

jmpScanPort@SetConfigParameters:
			lodsb
			cmp AL, R8b
			jb jmpGetPort@SetConfigParameters

			cmp AL, R9b 
			ja jmpGetPort@SetConfigParameters

				sub AL, R8b
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
		xor RAX, RAX
		param 4, RAX
		param 5, RAX
		inc RAX
		param 6, RAX
		param 3, IPPROTO_TCP
		param 2, SOCK_STREAM
		param 1, AF_INET
		call [WSASocket]

		mov  DL, SYS_ERR_Socket
		cmp EAX, INVALID_SOCKET
		je jmpEnd@SetConfigParameters

		mov RDI, [SetListSocket]
		stosq
		mov [SystemReport.Socket],  RAX
		mov [SetListSocket], RDI
;------------------------------------------------
;       * * *  Option SocketPort
;------------------------------------------------
		param 1, RAX
		param 5, 8
		param 4, SetOptionPort
		param 3, SO_REUSEADDR
		param 2, SOL_SOCKET
		call [setsockopt]

		mov DL, SYS_ERR_Option
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Binding
;------------------------------------------------
		param 3, 0
		mov R8b, SOCKADDR_IN_SIZE
		param 2, Address
		param 1, [SystemReport.Socket]
		call [bind]

		mov DL, SYS_ERR_Binding
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Listen
;------------------------------------------------
		param 2, [ServerConfig.MaxConnections]
		param 1, [SystemReport.Socket]
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
		mov RDI, [SetNetEvent]
		stosq
		mov [SetNetEvent], RDI

		param 2, RAX
		param 3, FD_ACCEPT + FD_CLOSE
		param 1, [SystemReport.Socket]
		call [WSAEventSelect]

		mov DL, SYS_ERR_SetEvent
		or EAX, EAX
		jnz jmpEnd@SetConfigParameters
;------------------------------------------------
;       * * *  Get HostProcess
;------------------------------------------------
		mov RSI, [SystemReport.NetHost]
		mov RCX, [RSI+NET_HOST.hProcess]
		jECXz jmpReport@SetConfigParameters

			inc RCX
;           param 1, RCX
			call GetMethodProcess
			mov   DL, SYS_ERR_HostProc

			or EAX, EAX
			jz jmpEnd@SetConfigParameters

				mov RSI, [SystemReport.NetHost]
				mov [RSI+NET_HOST.hProcess], RAX
;------------------------------------------------
;       * * *  ListenReport
;------------------------------------------------
jmpReport@SetConfigParameters:
;		mov CX, [Address.sin_port]
;		xchg CL, CH
;		mov [SystemReport.Socket], RCX

		param 0, SystemReport
		call WriteReport

		add [SystemReport.NetHost], NET_HOST_SIZE
		jmp jmpListenLoop@SetConfigParameters
;------------------------------------------------
;       * * *  Socket Port
;------------------------------------------------
jmpSocketPort@SetConfigParameters:
	param 1, 0
	param 2, RCX
	param 3, RCX
	param 4, RCX
	dec RCX
	call [CreateIoCompletionPort]

	mov DL, SYS_ERR_SocketPort
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		 mov [hPortIOSocket], RAX
;------------------------------------------------
;       * * *  Set Report Buffers
;------------------------------------------------
	mov RDX, [ServerConfig.MaxConnections]
	shl EDX, 3
	mov [MaxQueuedProcess], RDX

	mov RAX, [ServerConfig.MaxReportStack]
	xor RBX, RBX
	mov  BL, REPORT_INFO_SIZE
	mul EBX
	mov [TabRouteReport], RAX
	mov [TabQueuedProcess], RAX

	add EDX, EAX
	add EDX, EAX
	add EDX, MAX_SOCKET * 4
;------------------------------------------------
;       * * *  Get ReportBuffers
;------------------------------------------------
	param 4, PAGE_READWRITE
	param 3, MEM_COMMIT
	param 1, 0
	call [VirtualAlloc]

	mov DL, SYS_ERR_TableBuffer
	or RAX, RAX
	jz jmpEnd@SetConfigParameters

		mov RDI, GetMemoryBuffer
		stosq
		add EAX, MAX_SOCKET * 4
		stosq
		stosq
		stosq
		mov RDX, [RDI]
		add RAX, RDX
		stosq
		stosq
		stosq
		add RAX, RDX
		stosq
		stosq
		stosq
		add [RDI], RAX
;------------------------------------------------
;       * * *  ProcessEvent
;------------------------------------------------
	param 1, 0
	param 2, RCX
	param 3, RCX
	param 4, RCX
	call [CreateEvent]

	mov DL, SYS_ERR_NetEvent
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		mov [RunProcessEvent], RAX
;------------------------------------------------
;       * * *  Thread Process
;------------------------------------------------
	param 1, 0
	param 6, RCX
	param 5, RCX
	param 4, RCX
	param 3, ThreadProcessor
	param 2, RCX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadProcess
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		param 1, RAX
		call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Socket
;------------------------------------------------
	param 1, 0
	param 6, RCX
	param 5, RCX
	param 4, RCX
	param 3, ThreadRouter
	param 2, RCX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadRouter
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		param 1, RAX
		call [CloseHandle]
;------------------------------------------------
;       * * *  Thread Listen
;------------------------------------------------
	param 1, 0
	param 6, RCX
	param 5, RCX
	param 4, RCX
	param 3, ThreadListener
	param 2, RCX
	call [CreateThread]

	mov DL, SYS_ERR_ThreadListen
	or EAX, EAX
	jz jmpEnd@SetConfigParameters

		param 1, RAX
		call [CloseHandle]

	xor RDX, RDX
;------------------------------------------------
;       * * *  End Proc  * * *
;------------------------------------------------
jmpEnd@SetConfigParameters:
	xor RAX, RAX
	mov AL,  64
	add RSP, RAX
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------