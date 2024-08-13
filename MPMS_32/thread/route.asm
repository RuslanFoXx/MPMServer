;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	THREAD: Router
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc ThreadRouter ThrControl

local Len  DWORD ?
;------------------------------------------------
	mov EDI, [TabSocketIoData]
	mov ECX, [ServerConfig.MaxConnections]
	xor EAX, EAX
	rep stosd

	inc EAX
	mov [ThreadSocketCtrl], EAX
;------------------------------------------------
;       * * *  Wait Completion
;------------------------------------------------
jmpWaitCompletionPort@Router:
	push WAIT_PORT_TIMEOUT   
	push lpSocketIoData
	push lpPortIoCompletion
	push TransferredBytes
	push [hPortIOSocket]
	call [GetQueuedCompletionStatus]

	mov ECX, [ThreadServerCtrl]
	or  ECX, ECX 
	jz jmpEnd@Router
;------------------------------------------------
;       * * *  ReportError
;------------------------------------------------
	or EAX, EAX
	jnz jmpSetSocket@Router

		mov [TransferredBytes], EAX

		call [WSAGetLastError]
		cmp EAX, WAIT_TIMEOUT
		je jmpWaitCompletionPort@Router

		mov  DL, SRV_MSG_BreakConnect
		cmp EAX, ERROR_NETNAME_DELETED
		je jmpCloseSocket@Router

			mov [RouterReport.Error], EAX
			mov [RouterReport.Index], EDX
;------------------------------------------------
;       * * *  SystemRouter
;------------------------------------------------
jmpSetSocket@Router:
	mov ESI, [lpSocketIoData]
	or  ESI, ESI
	jz jmpWaitCompletionPort@Router

	mov EDX, [lpPortIoCompletion]
	or  EDX, EDX
	jnz jmpCloseSocket@Router

	mov  DL, SRV_MSG_Disconnected
	mov ECX, [TransferredBytes]
	or  ECX, ECX
	jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  ServerRouter
;------------------------------------------------
	add [ESI+PORT_IO_DATA.TransferredBytes], ECX
	add [ESI+PORT_IO_DATA.WSABuffer.buf], ECX

	mov AX, [ESI+PORT_IO_DATA.Route]
	cmp AL, ROUTE_SEND_FILE
	je jmpSendFromFile@Router

	cmp AL, ROUTE_SEND_BUFFER
	je jmpSendFromBuffer@Router

	cmp AL, ROUTE_RECV_BUFFER
	je jmpRecvToBuffer@Router

	cmp AL, ROUTE_RECV_FILE
	je jmpRecvToFile@Router

	or AL, AL
	jnz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  Get Method
;------------------------------------------------
jmpAskRespond@Router:
	mov [ESI+PORT_IO_DATA.CountBytes], ECX

	lea EBX, [ESI+PORT_IO_DATA.Buffer]
	mov EDI, EBX
	mov DL, SRV_MSG_Method
	mov AL, ' '
	repne scasb
	jne jmpCloseSocket@Router

		mov EDX, EDI
		sub EDX, EBX
		dec EDX
		mov [pFind], EBX
;------------------------------------------------
;       * * *  Find Method
;------------------------------------------------
	mov EBX, DefAskMethod
	mov [ESI+PORT_IO_DATA.Method], EBX

jmpFindMethod@Router:
	add EBX, ASK_METHOD_SIZE
	mov ESI, [EBX]
	or  ESI, ESI
	jz jmpMethodToProcess@Router

		xor EAX, EAX
		lodsb
		cmp EAX, EDX 
		jne jmpFindMethod@Router

		mov EDI, [pFind]
		mov ECX, EDX
		repe cmpsb
		jne jmpFindMethod@Router

			mov ESI, [lpSocketIoData]
			mov [ESI+PORT_IO_DATA.Method], EBX
			jmp jmpMethodToProcess@Router
;------------------------------------------------
;       * * *  METHOD To Process  * * *
;------------------------------------------------
jmpPostError@Router:
	call PostReport

jmpMethodToProcess@Router:
	mov EDI, [SetQueuedProcess]
	lea EAX, [EDI+4]

	cmp EAX, [MaxQueuedProcess]
	jb jmpSetProcess@Router
		mov EAX, [TabQueuedProcess]

jmpSetProcess@Router:
	mov  DL, SRV_MSG_ProcessLimit
	cmp EAX, [GetQueuedProcess]
	je jmpCloseSocket@Router
		mov [SetQueuedProcess], EAX

		mov EAX, [lpSocketIoData] 
		mov [EDI], EAX

		push [RunProcessEvent]
		call [SetEvent]
		jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  Send From Buffer
;------------------------------------------------
jmpSendFromBuffer@Router:
	sub [ESI+PORT_IO_DATA.CountBytes], ECX

	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	mov DL,  SRV_MSG_Send
	xor EAX, EAX
	cmp ECX, EAX 
	jg jmpSending@Router
;------------------------------------------------
;       * * *  RECV To Method
;------------------------------------------------
		cmp AX, [ESI+PORT_IO_DATA.Connection]
		je jmpCloseSocket@Router

			call PostReport

			mov ESI, [lpSocketIoData] 
			lea EDI, [ESI+PORT_IO_DATA.Method]
			mov ECX, PORT_CLEAR_COUNT
			xor EAX, EAX
			rep stosd

			lea EDX, [ESI+PORT_IO_DATA.Buffer]
			mov [ESI+PORT_IO_DATA.WSABuffer.buf], EDX

			mov EAX, [ServerConfig.MaxHeadSize]
			jmp jmpReceiving@Router
;------------------------------------------------
;       * * *  Send From File
;------------------------------------------------
jmpSendFromFile@Router:
	sub [ESI+PORT_IO_DATA.CountBytes], ECX

	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	cmp ECX, [ServerConfig.MaxSendSize] 
	jg jmpSending@Router
;------------------------------------------------
;       * * *  Copy Buffer
;------------------------------------------------
		mov [CountBytes], ECX
		mov EBX, [ServerConfig.MaxBufferSize]
		sub EBX, ECX

		mov EAX, [ESI+PORT_IO_DATA.WSABuffer.buf]
		lea EDX, [ESI+PORT_IO_DATA.Buffer]
		mov [ESI+PORT_IO_DATA.WSABuffer.buf], EDX

		xchg ESI, EAX
		mov  EDI, EDX
		add  EDX, ECX
		rep movsb
;------------------------------------------------
;       * * *  Read Buffer
;------------------------------------------------
		mov ESI, EAX
		mov EAX, [ESI+PORT_IO_DATA.TotalBytes]
		cmp EAX, EBX
		jb jmpReadSend@Router
			mov EAX, EBX
;------------------------------------------------
;       * * *  Read SendFile
;------------------------------------------------
jmpReadSend@Router:
;       xor ECX, ECX
		push ECX
		push TotalBytes
		push EAX
		push EDX
		push [ESI+PORT_IO_DATA.hFile]
		call [ReadFile]

		mov DL, SRV_ERR_ReadFile
		or EAX, EAX
		jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  SendBuffer
;------------------------------------------------
			mov ESI, [lpSocketIoData] 
			mov EBX, [ESI+PORT_IO_DATA.TotalBytes]
			mov ECX, [CountBytes]
			mov EAX, [TotalBytes]
			add ECX, EAX
			sub EBX, EAX
			mov [CountBytes], ECX
			mov [ESI+PORT_IO_DATA.CountBytes], ECX
			mov [ESI+PORT_IO_DATA.TotalBytes], EBX

			or EBX, EBX
			jnz jmpSendBytes@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
jmpCloseSend@Router:
				push [ESI+PORT_IO_DATA.hFile]
				xor EAX, EAX
				mov [ESI+PORT_IO_DATA.hFile], EAX
				call [CloseHandle]

				mov DL, SRV_ERR_ReadClose
				or EAX, EAX
				jz jmpCloseSocket@Router

					mov ESI, [lpSocketIoData] 
					xor EAX, EAX
					mov [ESI+PORT_IO_DATA.hFile], EAX
					mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

jmpSendBytes@Router:
			mov ECX, [CountBytes]
;------------------------------------------------
;       * * *  Sending
;------------------------------------------------
jmpSending@Router:
	mov EAX, [ServerConfig.MaxSendSize]
	cmp ECX, EAX
	jb jmpSizeSend@Router
		mov ECX, EAX

jmpSizeSend@Router:
	mov [ESI+PORT_IO_DATA.WSABuffer.len], ECX
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
	jz jmpWaitCompletionPort@Router

		call [WSAGetLastError]
		cmp EAX, ERROR_IO_PENDING
		je jmpWaitCompletionPort@Router

	mov DL, SRV_ERR_SendRouter
	jmp jmpCloseSocket@Router
;------------------------------------------------
;       * * *  RECV To File
;------------------------------------------------
jmpRecvToFile@Router:
	add [ESI+PORT_IO_DATA.CountBytes], ECX

	mov EAX, [ESI+PORT_IO_DATA.TotalBytes]
	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	cmp ECX, [ServerConfig.MaxRecvBufferSize]
	ja jmpWriteFile@Router

	cmp ECX, EAX
	jb jmpReceiving@Router
;------------------------------------------------
;       * * *  Write File
;------------------------------------------------
jmpWriteFile@Router:
		xor EAX, EAX
		mov [ESI+PORT_IO_DATA.CountBytes], EAX
		push EAX
		push TotalBytes
		push ECX
		lea EAX, [ESI+PORT_IO_DATA.Buffer]
		mov [ESI+PORT_IO_DATA.WSABuffer.buf], EAX
		push EAX
		push [ESI+PORT_IO_DATA.hFile]
		call [WriteFile]

		mov DL, SRV_ERR_WriteFile
		or EAX, EAX
		jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  Reset Buffer
;------------------------------------------------
			mov ESI, [lpSocketIoData] 
			mov EAX, [ESI+PORT_IO_DATA.TotalBytes]
			sub EAX, [TotalBytes]
			jc jmpSaveSize@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
				mov [ESI+PORT_IO_DATA.TotalBytes], EAX
				or  EAX, EAX
				jnz jmpReceiving@Router
jmpRecvClose@Router:
					push [ESI+PORT_IO_DATA.hFile]
					call [CloseHandle]
					mov DL, SRV_ERR_SaveClose
					or EAX, EAX
					jz jmpCloseSocket@Router

						mov ESI, [lpSocketIoData]
						xor EAX, EAX
						mov [ESI+PORT_IO_DATA.hFile], EAX

						mov DL, SRV_MSG_Save
						jmp jmpPostError@Router
jmpSaveSize@Router:
			mov  DL, SRV_ERR_SaveSize
			call PostReport
			jmp jmpRecvClose@Router
;------------------------------------------------
;       * * *  RECV To Buffer
;------------------------------------------------
jmpRecvToBuffer@Router:
	add [ESI+PORT_IO_DATA.CountBytes], ECX

	mov  DL, SRV_ERR_RecvSize
	mov EAX, [ESI+PORT_IO_DATA.TotalBytes]
	mov ECX, [ESI+PORT_IO_DATA.CountBytes]
	cmp ECX, EAX
	je jmpMethodToProcess@Router
	ja jmpPostError@Router
;------------------------------------------------
;       * * *  Receiving
;------------------------------------------------
jmpReceiving@Router:
	mov ESI, [lpSocketIoData] 
	mov ECX, [ServerConfig.MaxRecvSize]
	cmp EAX, ECX
	jb jmpSizeRecv@Router
		mov EAX, ECX

jmpSizeRecv@Router:
	mov [ESI+PORT_IO_DATA.WSABuffer.len], EAX
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
	jz jmpWaitCompletionPort@Router

		call [WSAGetLastError]
		cmp EAX, ERROR_IO_PENDING
		je jmpWaitCompletionPort@Router

			mov DL, SRV_ERR_RecvRouter
;------------------------------------------------
;       * * *  Close SocketPort
;------------------------------------------------
jmpCloseSocket@Router:
	call PostReport

	mov ESI, [lpSocketIoData]
	mov EDI, [ESI+PORT_IO_DATA.TablePort]
	xor EAX, EAX
	mov [EDI], EAX

	mov  EAX, [ESI+PORT_IO_DATA.Socket]
	push EAX
	push SD_BOTH
	push EAX
	call [shutdown]

	or EAX, EAX
	jz jmpClose@Router

		mov  DL, SRV_ERR_ShutDown
		call PostReport

jmpClose@Router:
	call [closesocket]
	or EAX, EAX
	jz jmpCloseFile@Router

		mov  DL, SRV_ERR_SocketClose
		call PostReport
;------------------------------------------------
;       * * *  Close ReadFile / WriteFile
;------------------------------------------------
jmpCloseFile@Router:
	mov ESI, [lpSocketIoData]
	mov ECX, [ESI+PORT_IO_DATA.hFile]
	jECXz jmpSocketFree@Router

		push ECX
		call [CloseHandle]

jmpSocketFree@Router:
	mov  DL, SRV_MSG_Close
	call PostReport

	push MEM_RELEASE
	xor EAX, EAX
	push EAX
	push [lpSocketIoData]
	call [VirtualFree]
	jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
jmpEnd@Router:
	xor EAX, EAX
	mov [ThreadSocketCtrl], EAX
	push EAX
	call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------