;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	THREAD: Thread of Processor
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc ThreadProcessor ThrControl

local hProcess   HANDLE ?
local lpProcessIoData LPPORT_IO_DATA ?
;------------------------------------------------
	xor EAX, EAX
	inc EAX
	mov [CountProcess], EAX
	mov [dSecurity.bInheritHandle], EAX
	mov [dSecurity.nLength], SECURITY_ATTRIBUTES_SIZE
	mov [StartRunInfo.cb], STARTUPINFO_SIZE
;------------------------------------------------
;   * * *  Wait Process
;------------------------------------------------
jmpWaitProcess@Processor:
	push WAIT_PROC_TIMEOUT
	xor EAX, EAX
	push EAX
	push RunProcessEvent
	push [CountProcess]
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
	lea EDI, [EAX*4]

	mov EAX, [CountProcess]
	dec EAX
	mov [CountProcess], EAX
	lea ESI, [EAX*4]

	mov EDX, [RunProcessEvent+EDI]
	mov [hProcess], EDX

	mov EBX, [RunProcessSocket+EDI]
	mov [lpProcessIoData], EBX

	mov EAX, [RunProcessEvent+ESI]
	mov [RunProcessEvent+EDI], EAX

	mov EAX, [RunProcessSocket+ESI]
	mov [RunProcessSocket+EDI], EAX
;------------------------------------------------
;   * * *  GetProcReturn
;------------------------------------------------
	lea  EAX, [EBX+PORT_IO_DATA.ExitCode]
	push EAX
	push EDX
	call [GetExitCodeProcess]

	mov DL, PRC_ERR_ExitProc
	or EAX, EAX
	jz jmpReport@Processor

		mov ESI, [lpProcessIoData]
		push PipeBytes
		push [ESI+PORT_IO_DATA.hFile]
		call [GetFileSizeEx]
		mov DL, PRC_ERR_PipeSize
		or EAX, EAX
		jz jmpReport@Processor

			push [hProcess]
			call [CloseHandle]
;------------------------------------------------
;       * * *  Run Method
;------------------------------------------------
	mov ESI, [lpProcessIoData]
	mov EAX, [PipeBytes]
	mov [ESI+PORT_IO_DATA.TotalBytes], EAX
	jmp jmpRunMethod@Processor
;------------------------------------------------
;       * * *  Get QueuedSocket
;------------------------------------------------
jmpGetProcess@Processor:
	xor EAX, EAX
	mov  AL, MAXIMUM_WAIT_OBJECTS-1
	cmp EAX, [CountProcess]
	jbe jmpWaitProcess@Processor

		mov ESI, [GetQueuedProcess]
		cmp ESI, [SetQueuedProcess]
		je jmpWaitProcess@Processor

			lodsd

			cmp ESI, [MaxQueuedProcess]
			jb jmpSetProcess@Processor
				mov ESI, [TabQueuedProcess]

jmpSetProcess@Processor:
	mov [GetQueuedProcess], ESI
	mov ESI, EAX
	mov [lpProcessIoData], EAX
;------------------------------------------------
;       * * *  Get Method
;------------------------------------------------
jmpRunMethod@Processor:
	mov EDI, [ESI+PORT_IO_DATA.Method]
	push ESI
	call [EDI+ASK_METHOD.hProcess]
;------------------------------------------------
;       * * *  Select Route
;------------------------------------------------
	mov ESI, [lpProcessIoData]
	mov [ESI+PORT_IO_DATA.ExitCode], EAX

	mov  AX, [ESI+PORT_IO_DATA.Route]
	test AL, SET_PROC_BIT
	jnz jmpProcessToPipe@Processor

	test AL, SET_SEND_BIT
	jz jmpRecieverToPipe@Processor
;------------------------------------------------
;       * * *  Sending From Pipe
;------------------------------------------------
	lea EAX, [ESI+PORT_IO_DATA.Buffer]
	mov [ESI+PORT_IO_DATA.WSABuffer.buf], EAX

	mov EAX, [ESI+PORT_IO_DATA.CountBytes]
	mov ECX, [ServerConfig.MaxSendSize]
	cmp EAX, ECX
	jb jmpSizeSend@Processor
		mov EAX, ECX

jmpSizeSend@Processor:
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
	push [ESI+PORT_IO_DATA.Socket]
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
	mov EAX, [ESI+PORT_IO_DATA.TotalBytes]
	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	cmp EAX, ECX
	jbe jmpRunMethod@Processor
;------------------------------------------------
;       * * *  Create Resourse
;------------------------------------------------
	mov EBX, [ServerConfig.MaxRecvSize]
	sub EBX, ECX
	sub EAX, ECX
	cmp EBX, EAX
	jb jmpReceiving@Processor
		mov EBX, EAX
;------------------------------------------------
;       * * *  Receiving
;------------------------------------------------
jmpReceiving@Processor:
	mov EAX, [ServerConfig.MaxRecvSize]
	cmp EBX, EAX
		ja jmpSizeRecv@Processor
		mov EBX, EAX

jmpSizeRecv@Processor:
	mov [ESI+PORT_IO_DATA.WSABuffer.len], EBX
	xor EAX, EAX
	push EAX
	push ESI
	push TransFlag
	push TransBytes
	inc EAX
	push EAX
	lea EAX, [ESI+PORT_IO_DATA.WSABuffer]
	push EAX
	push [ESI+PORT_IO_DATA.Socket]
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
	mov EDI, [ESI+PORT_IO_DATA.Method]
	mov EAX, [EDI+ASK_METHOD.RunPath]
	or  EAX, [EDI+ASK_METHOD.CmdLine]
	jz jmpReport@Processor
;------------------------------------------------
;   * * *  Set ProcStruct
;------------------------------------------------
	xor EAX, EAX
	mov ECX, EAX
	mov EDI, StartRunInfo + 4
	mov CL,  STARTUPINFO_COUNT + PROCESS_INFORMATION_COUNT-1
	rep stosd

	mov [StartRunInfo.wShowWindow], SW_HIDE
	mov [StartRunInfo.dwFlags], STARTF_USESTDHANDLES
;------------------------------------------------
;   * * *  Create InPipe
;------------------------------------------------
jmpInPipe@Processor:
	mov  ESI, [lpProcessIoData]
	mov  ECX, [ESI+PORT_IO_DATA.CountBytes]
	mov [PipeBytes], ECX

	push ECX
	push dSecurity
	push hInPipe
	push StartRunInfo.hStdInput
	call [CreatePipe]

	mov DL, PRC_ERR_PipeIn
	or EAX, EAX
	jz jmpReport@Processor

		mov ESI, [lpProcessIoData]
		mov EAX, [StartRunInfo.hStdInput]
		mov [ESI+PORT_IO_DATA.hFile], EAX
		xor EAX, EAX
		push EAX
		push PipeBytes
		push [PipeBytes]
		lea EAX, [ESI+PORT_IO_DATA.Buffer]
		push EAX
		push [hInPipe]
		call [WriteFile]

		mov DL, PRC_ERR_PipeWrite
		or EAX, EAX
		jz jmpReport@Processor

			push [hInPipe]
			call [CloseHandle]
;------------------------------------------------
;   * * *  Create StdPipe
;------------------------------------------------
jmpOutPipe@Processor:
	push [ServerConfig.MaxPipeSize]
	push dSecurity
	push StartRunInfo.hStdOutput
	push hOutPipe
	call [CreatePipe]

	mov DL, PRC_ERR_PipeOut
	or EAX, EAX
	jz jmpReport@Processor

		xor EAX, EAX
		push EAX

		inc EAX
		push EAX
		push [hOutPipe]
		call [SetHandleInformation]

		mov EAX, [StartRunInfo.hStdOutput]
		mov [StartRunInfo.hStdError], EAX

		mov ESI, [lpProcessIoData]
		mov EAX, [hOutPipe]
		mov [ESI+PORT_IO_DATA.hFile], EAX
;------------------------------------------------
;   * * *  Greate RunProcess
;------------------------------------------------
	push ProcRunInfo
	push StartRunInfo
	mov  EDI,[ESI+PORT_IO_DATA.Method]
	push [EDI+ASK_METHOD.Directory]
	xor EAX, EAX
	push EAX
	push EAX
	inc EAX
	push EAX
	xor EAX, EAX
	push EAX
	push EAX
	push [EDI+ASK_METHOD.CmdLine]
	push [EDI+ASK_METHOD.RunPath]
	call [CreateProcess]

	mov DL, PRC_ERR_RunProc
	or EAX, EAX
	jz jmpReport@Processor
;------------------------------------------------
;   * * *  Set Handle
;------------------------------------------------
		push [ProcRunInfo.hThread]
		call [CloseHandle]

		mov EBX, [lpProcessIoData]
		mov EDI, [CountProcess]
		mov EAX, [ProcRunInfo.hProcess]

		mov [EBX+PORT_IO_DATA.Route], ROUTE_SEND_FILE
		mov [EBX+PORT_IO_DATA.hProcess], EAX
		mov [RunProcessEvent +EDI*4], EAX
		mov [RunProcessSocket+EDI*4], EBX
		inc [CountProcess]
		jmp jmpGetProcess@Processor
;------------------------------------------------
;   * * *  Get AllError
;------------------------------------------------
jmpReport@Processor:
	mov  [SystemReport.Index], EDX
	call [GetLastError]

	mov ESI, [lpProcessIoData]
	mov [ESI+PORT_IO_DATA.ExitCode], EAX

	push ESI
	push [SystemReport.Index]
	push EAX
	push [hPortIOSocket]
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
	mov ESI, RunProcessEvent
	mov ECX, [CountProcess]

jmpFreeProc@Processor:
	lodsd
	mov [hProcess], EAX

	push ECX
	push ESI
	push PipeBytes
	push EAX
	call [GetExitCodeProcess]

	or EAX, EAX
	jz jmpNextProc@Processor  

		mov EAX, [PipeBytes]
		cmp EAX, STILL_ACTIVE 
		jne jmpNextProc@Processor

			xor EAX, EAX
			push EAX
			push [hProcess]
			call [TerminateProcess]

jmpNextProc@Processor:
	push [hProcess]
	call [CloseHandle]

	pop ESI
	pop ECX
	loop jmpFreeProc@Processor
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
	mov [ThreadProcessCtrl], ECX
	push ECX
	call [ExitThread]
endp
;------------------------------------------------
;   * * *  END  * * *
;------------------------------------------------
