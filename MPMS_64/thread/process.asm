;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	THREAD: Thread of Processor
;	ver.1.75 (x64)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc ThreadProcessor   ;   RCX = ThrControl

local  hProcess   HANDLE ?
local  lpProcessIoData LPPORT_IO_DATA ?
;------------------------------------------------
	xor RAX, RAX
	inc EAX
	mov [CountProcess], RAX
	mov [dSecurity.bInheritHandle], RAX

	mov AL, SECURITY_ATTRIBUTES_SIZE
	mov [dSecurity.nLength], RAX

	mov AL, STARTUPINFO_SIZE
	mov [StartRunInfo.cb], EAX

	mov AL,  80
	sub RSP, RAX
;------------------------------------------------
;   * * *  Wait Process
;------------------------------------------------
jmpWaitProcess@Processor:
	param 4, WAIT_PROC_TIMEOUT
	param 3, 0
	param 2, RunProcessEvent
	param 1, [CountProcess]
	call [WaitForMultipleObjects]

	or EAX, EAX
	jz jmpGetProcess@Processor

	cmp EAX, WAIT_FAILED
	je jmpWaitError@Processor

	mov ECX, [ThreadServerCtrl]
	or  ECX, ECX 
	jz jmpEnd@Processor

	cmp EAX, WAIT_TIMEOUT
	je jmpWaitProcess@Processor
;------------------------------------------------
;       * * *  Get ProcEvent
;------------------------------------------------
	lea RDI, [RAX*8]

	mov RAX, [CountProcess]
	dec RAX
	mov [CountProcess], RAX
	lea RSI, [RAX*8]

	mov RBX, [RunProcessSocket+RDI]
	mov [lpProcessIoData], RBX

	mov RCX, [RunProcessEvent+RDI]
	mov [hProcess], RCX

	mov RAX, [RunProcessEvent+RSI]
	mov [RunProcessEvent+RDI], RAX

	mov RAX, [RunProcessSocket+RSI]
	mov [RunProcessSocket+RDI], RAX
;------------------------------------------------
;   * * *  GetProcReturn
;------------------------------------------------
	lea RDX, [RBX+PORT_IO_DATA.ExitCode]
	call [GetExitCodeProcess]

	mov DL, PRC_ERR_ExitProc
	or EAX, EAX
	jz jmpReport@Processor

		mov RSI, [lpProcessIoData]
		lea RDX, [RSI+PORT_IO_DATA.TotalBytes]
		param 1, [RSI+PORT_IO_DATA.hFile]
		call [GetFileSizeEx]

		mov DL, PRC_ERR_PipeSize
		or EAX, EAX
		jz jmpReport@Processor

			param 1, [hProcess]
			call [CloseHandle]
;------------------------------------------------
;       * * *  Run Method
;------------------------------------------------
	mov RSI, [lpProcessIoData]
	jmp jmpRunMethod@Processor
;------------------------------------------------
;       * * *  Get QueuedSocket
;------------------------------------------------
jmpGetProcess@Processor:
	xor RAX, RAX
	mov  AL, MAXIMUM_WAIT_OBJECTS-1
	cmp RAX, [CountProcess]
	jbe jmpWaitProcess@Processor

		mov RSI, [GetQueuedProcess]
		cmp RSI, [SetQueuedProcess]
		je jmpWaitProcess@Processor

			lodsq

			cmp RSI, [MaxQueuedProcess]
			jb jmpSetProcess@Processor
				mov RSI, [TabQueuedProcess]

jmpSetProcess@Processor:
	mov [GetQueuedProcess], RSI
	mov RSI, RAX
	mov [lpProcessIoData], RAX
;------------------------------------------------
;       * * *  Get Method
;------------------------------------------------
jmpRunMethod@Processor:
	mov RDI, [RSI+PORT_IO_DATA.Method]
	param 1, RSI
	call [RDI+ASK_METHOD.hProcess]
;------------------------------------------------
;       * * *  Select Route
;------------------------------------------------
	mov  RSI, [lpProcessIoData]
	mov [RSI+PORT_IO_DATA.ExitCode], EAX

	mov  AX, [RSI+PORT_IO_DATA.Route]
	test AL, SET_PROC_BIT
	jnz jmpProcessToPipe@Processor

	test AL, SET_SEND_BIT
	jz jmpRecieverToPipe@Processor
;------------------------------------------------
;       * * *  Sending From Pipe
;------------------------------------------------
	lea RAX, [RSI+PORT_IO_DATA.Buffer]
	mov [RSI+PORT_IO_DATA.WSABuffer.buf], RAX

	mov RAX, [RSI+PORT_IO_DATA.CountBytes]
	mov RCX, [ServerConfig.MaxSendSize]
	cmp RAX, RCX
	jb jmpSizeSend@Processor
		mov RAX, RCX

jmpSizeSend@Processor:
	mov [RSI+PORT_IO_DATA.WSABuffer.len], RAX
	param 3, 0
	param 7, R8
	param 6, RSI
	param 5, R8
	inc R8
	param 4, TransBytes
	lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
	param 1, [RSI+PORT_IO_DATA.Socket]
	call [WSASend]

	or EAX, EAX
	jz jmpGetProcess@Processor

		call [WSAGetLastError]
		cmp EAX, ERROR_IO_PENDING
		je jmpGetProcess@Processor
	
	mov DL, SRV_ERR_SendPipe
	jmp jmpReport@Processor
;------------------------------------------------
;       * * *  Reciever To Pipe
;------------------------------------------------
jmpRecieverToPipe@Processor:
	mov RAX, [ESI+PORT_IO_DATA.TotalBytes]
	mov RCX, [ESI+PORT_IO_DATA.CountBytes]
	cmp RAX, RCX
	jbe jmpRunMethod@Processor
;------------------------------------------------
;       * * *  Create Resourse
;------------------------------------------------
	mov RBX, [ServerConfig.MaxRecvSize]
	sub RBX, RCX
	sub RAX, RCX
	cmp RBX, RAX
	jb jmpReceiving@Processor
		mov RBX, RAX
;------------------------------------------------
;       * * *  Receiving
;------------------------------------------------
jmpReceiving@Processor:
	mov RAX, [ServerConfig.MaxRecvSize]
	cmp RBX, RAX
	jb jmpSizeRecv@Processor
		mov RBX, RAX

jmpSizeRecv@Processor:
	mov [RSI+PORT_IO_DATA.WSABuffer.len], RBX
	param 3, 0
	param 7, R8
	param 6, RSI
	param 5, TransFlag
	param 4, TransBytes
	inc R8
	lea RDX, [RSI+PORT_IO_DATA.WSABuffer]
	param 1, [RSI+PORT_IO_DATA.Socket]
	call [WSARecv] 

	or EAX, EAX
	jz jmpGetProcess@Processor

		call [WSAGetLastError]
		cmp EAX, ERROR_IO_PENDING
		je jmpGetProcess@Processor

	mov DL, SRV_ERR_RecvPipe
	jmp jmpReport@Processor
;------------------------------------------------
;       * * *  GetQueueProcess
;------------------------------------------------
jmpProcessToPipe@Processor:
	mov  DL, PRC_ERR_RunProc
	mov RDI, [RSI+PORT_IO_DATA.Method]
	mov RAX, [RDI+ASK_METHOD.RunPath]
	or  RAX, [RDI+ASK_METHOD.CmdLine]
	jz jmpReport@Processor
;------------------------------------------------
;   * * *  Set ProcStruct
;------------------------------------------------
	mov  DL, PRC_ERR_RunProc
	cmp [CountProcess], MAXIMUM_WAIT_OBJECTS-1
	ja jmpReport@Processor
;------------------------------------------------
;   * * *  Set ProcStruct
;------------------------------------------------
	xor RAX, RAX
	mov RCX, RAX
	mov RDI, RAX
	mov RDI, StartRunInfo+8
	mov  CL, STARTUPINFO_COUNT + PROCESS_INFORMATION_COUNT-1
	rep stosq

	mov [StartRunInfo.wShowWindow], SW_HIDE
	mov [StartRunInfo.dwFlags], STARTF_USESTDHANDLES
;------------------------------------------------
;   * * *  Create InPipe
;------------------------------------------------
	mov  RSI, [lpProcessIoData]
	mov  RCX, [RSI+PORT_IO_DATA.CountBytes]
	mov [PipeBytes], RCX

	param 4, RCX
	param 3, dSecurity
	param 2, hInPipe
	param 1, StartRunInfo.hStdInput
	call [CreatePipe]

	mov DL, PRC_ERR_PipeIn
	or EAX, EAX
	jz jmpReport@Processor

		mov RSI, [lpProcessIoData]
		mov RAX, [StartRunInfo.hStdInput]
		mov [RSI+PORT_IO_DATA.hFile], RAX
		param 5, 0
		param 4, PipeBytes
		param 3, [PipeBytes]
		lea RDX, [RSI+PORT_IO_DATA.Buffer]
		param 1, [hInPipe]
		call [WriteFile]

		mov DL, PRC_ERR_PipeWrite
		or EAX, EAX
		jz jmpReport@Processor

			param 1, [hInPipe]
			call [CloseHandle]
;------------------------------------------------
;   * * *  Create StdPipe
;------------------------------------------------
jmpOutPipe@Processor:
	param 4, [ServerConfig.MaxPipeSize]
	param 3, dSecurity
	param 2, StartRunInfo.hStdOutput
	param 1, hOutPipe
	call [CreatePipe]

	mov DL, PRC_ERR_PipeOut
	or EAX, EAX
	jz jmpReport@Processor

		param 1, [hOutPipe]
		param 2, 0
		param 3, RDX
		inc RDX
		call [SetHandleInformation]

		mov RAX, [StartRunInfo.hStdOutput]
		mov [StartRunInfo.hStdError], RAX

		mov RSI, [lpProcessIoData]
		mov RAX, [hOutPipe]
		mov [RSI+PORT_IO_DATA.hFile], RAX
;------------------------------------------------
;   * * *  Greate RunProcess
;------------------------------------------------
	param 10, ProcRunInfo
	param 9, StartRunInfo
	mov RDI, [RDI+PORT_IO_DATA.Method]
	mov RAX, [RDI+ASK_METHOD.Directory]
	param 8, RAX
	xor RAX, RAX
	param 7, RAX
	param 6, RAX
	param 4, RAX
	param 3, RAX
	inc EAX
	param 5, RAX
	param 2, [RDI+ASK_METHOD.CmdLine]
	param 1, [RDI+ASK_METHOD.RunPath]
	call [CreateProcess]

	mov DL, PRC_ERR_RunProc
	or EAX, EAX
	jz jmpReport@Processor
;------------------------------------------------
;   * * *  Set Handle
;------------------------------------------------
		param 1, [ProcRunInfo.hThread]
		call [CloseHandle]

		mov RBX, [lpProcessIoData]
		mov RDI, [CountProcess]
		mov RAX, [ProcRunInfo.hProcess]

		mov [RBX+PORT_IO_DATA.hProcess], RAX
		mov [EBX+PORT_IO_DATA.Route], ROUTE_SEND_FILE
		mov [RunProcessEvent +RDI*8], RAX
		mov [RunProcessSocket+RDI*8], RBX
		inc [CountProcess]
		jmp jmpGetProcess@Processor
;------------------------------------------------
;   * * *  Get AllError
;------------------------------------------------
jmpReport@Processor:
	mov  [SystemReport.Index], EDX
	call [GetLastError]

	mov RSI, [lpProcessIoData]
	mov [RSI+PORT_IO_DATA.ExitCode], EAX

	param 2, 0
	param 3, RDX
	param 4, RSI
	mov EDX, [SystemReport.Index]
	param 1, [hPortIOSocket]
	param 1, [hPortIOSocket]
	call [PostQueuedCompletionStatus]

	or EAX, EAX
	jnz jmpGetProcess@Processor
;------------------------------------------------
;       * * *  Process Error
;------------------------------------------------
jmpWaitError@Processor:
	call [GetLastError]
	mov  [SystemReport.Error], EAX
	mov  [SystemReport.Index], PRC_ERR_WaitProc
;------------------------------------------------
;   * * *  Terminate All Processes
;------------------------------------------------
jmpEnd@Processor:
	mov RSI, RunProcessEvent

jmpFreeProc@Processor:
	lodsq
	mov [hProcess], RAX
	mov [SetOptionPort], RSI

	param 1, RAX
	param 2, PipeBytes
	call [GetExitCodeProcess]

	or EAX, EAX
	jz jmpNextProc@Processor  

		mov RAX, [PipeBytes]
		cmp EAX, STILL_ACTIVE 
		jne jmpNextProc@Processor

			param 1, [hProcess]
			param 2, 0
			call [TerminateProcess]

jmpNextProc@Processor:
	param 1, [hProcess]
	call [CloseHandle]

	mov RSI, [SetOptionPort]
	dec [CountProcess]
	jnz jmpFreeProc@Processor
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
	xor RAX, RAX
	param 1, RAX
	mov [ThreadProcessCtrl], EAX
	mov AL,  80
	add RSP, RAX
	call [ExitThread]
endp
;------------------------------------------------
;   * * *  END  * * *
;------------------------------------------------
