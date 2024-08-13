;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	THREAD: Router
;	ver.1.75 (x64)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
proc ThreadRouter   ;   RCX = ThrControl

	mov RDI, [TabSocketIoData]
	mov RCX, [ServerConfig.MaxConnections]
	xor RAX, RAX
	rep stosq
	inc RAX
	mov [ThreadSocketCtrl], EAX
	mov AL,  64
	sub RSP, RAX
;------------------------------------------------
;       * * *  Wait Completion
;------------------------------------------------
jmpWaitCompletionPort@Router:

	param 5, WAIT_PORT_TIMEOUT
	param 4, lpSocketIoData
	param 3, lpPortIoCompletion
	param 2, TransferredBytes
	param 1, [hPortIOSocket]
	call [GetQueuedCompletionStatus]

	mov ECX, [ThreadServerCtrl]
	or  ECX, ECX 
	jz jmpEnd@Router
;------------------------------------------------
;       * * *  ReportError
;------------------------------------------------
	or EAX, EAX
	jnz jmpSetSocket@Router

		mov [TransferredBytes], RAX

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
	mov RSI, [lpSocketIoData]
	or  RSI, RSI
	jz jmpWaitCompletionPort@Router

	mov RDX, [lpPortIoCompletion]
	or  EDX, EDX
	jnz jmpCloseSocket@Router

	mov  DL, SRV_MSG_Disconnected
	mov RCX, [TransferredBytes]
	or  ECX, ECX
	jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  ServerRouter
;------------------------------------------------
	add [RSI+PORT_IO_DATA.TransferredBytes], RCX
	add [RSI+PORT_IO_DATA.WSABuffer.buf], RCX

	mov AX, [RSI+PORT_IO_DATA.Route]
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
;       * * *  ASK
;------------------------------------------------
jmpAskRespond@Router:
	mov [RSI+PORT_IO_DATA.CountBytes], RCX

	lea R10, [RSI+PORT_IO_DATA.Buffer]
	mov R15, RSI
	mov RDI, R10
	mov DL, SRV_MSG_Method
	mov AL, ' '
	repne scasb
	jne jmpCloseSocket@Router

		mov EDX, EBX
		mov [pFind], RDI

		mov R9, RDI
		sub R9, R10
		dec R9
		xor R8, R8
		mov R8, ASK_METHOD_SIZE
;------------------------------------------------
;       * * *  Find Method
;------------------------------------------------
	mov RBX, DefAskMethod
	mov [RSI+PORT_IO_DATA.Method], RBX

jmpFindMethod@Router:
	add RBX, R8
	mov RSI, [RBX]
	or  RSI, RSI
	jz jmpMethodToProcess@Router

		xor EAX, EAX
		lodsb
		cmp EAX, R9d
		jne jmpFindMethod@Router

			mov RDI, R10
			mov RCX, R9
			repe cmpsb
			jne jmpFindMethod@Router

	mov [R15+PORT_IO_DATA.Method], RBX
	jmp jmpMethodToProcess@Router
;------------------------------------------------
;       * * *  METHOD To Process  * * *
;------------------------------------------------
jmpPostError@Router:
	call PostReport

jmpMethodToProcess@Router:

	mov RDI, [SetQueuedProcess]
	lea RAX, [RDI+8]
	cmp RAX, [MaxQueuedProcess]
	jb jmpSetProcess@Router
		mov RAX, [TabQueuedProcess]

jmpSetProcess@Router:
	mov  DL, SRV_MSG_ProcessLimit
	cmp RAX, [GetQueuedProcess]
	je jmpCloseSocket@Router

		mov [SetQueuedProcess], RAX
		mov RAX, [lpSocketIoData] 
		mov [RDI], RAX

		param 1, [RunProcessEvent]
		call [SetEvent]
		jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  Send From Buffer
;------------------------------------------------
jmpSendFromBuffer@Router:
	sub [RSI+PORT_IO_DATA.CountBytes], RCX

	mov RCX, [RSI+PORT_IO_DATA.CountBytes]
	mov  DL, SRV_MSG_Send
	xor RAX, RAX
	cmp RCX, RAX 
	jg jmpSending@Router
;------------------------------------------------
;       * * *  RECV To Method
;------------------------------------------------
		cmp AX, [RSI+PORT_IO_DATA.Connection]
		je jmpCloseSocket@Router

			call PostReport

			mov RSI, [lpSocketIoData] 
			lea RDI, [RSI+PORT_IO_DATA.Method]
			mov RCX, PORT_CLEAR_COUNT
			xor RAX, RAX
			rep stosq

			lea RDX, [RSI+PORT_IO_DATA.Buffer]
			mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX

			mov RAX, [ServerConfig.MaxHeadSize]
			jmp jmpReceiving@Router
;------------------------------------------------
;       * * *  Send From File
;------------------------------------------------
jmpSendFromFile@Router:
	sub [RSI+PORT_IO_DATA.CountBytes], RCX

	mov RCX, [RSI+PORT_IO_DATA.CountBytes]
	cmp RCX, [ServerConfig.MaxSendSize] 
	jg jmpSending@Router
;------------------------------------------------
;       * * *  Copy Buffer
;------------------------------------------------
		mov [CountBytes], RCX
		mov R10, [ServerConfig.MaxBufferSize]
		sub R10, RCX

		mov RBX, [RSI+PORT_IO_DATA.WSABuffer.buf]
		lea RDX, [RSI+PORT_IO_DATA.Buffer]
		mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX

		xchg RSI, RBX
		mov  RDI, RDX
		add  RDX, RCX
		rep movsb
;------------------------------------------------
;       * * *  Read Buffer
;------------------------------------------------
		mov R8, [RBX+PORT_IO_DATA.TotalBytes]
		cmp R8, R10
		jb jmpReadSend@Router
			mov R8, R10
;------------------------------------------------
;       * * *  Read SendFile
;------------------------------------------------
jmpReadSend@Router:
		param 5, RCX
		param 4, TotalBytes
		param 1, [RBX+PORT_IO_DATA.hFile]
		call [ReadFile]

		mov DL, SRV_ERR_ReadFile
		or EAX, EAX
		jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  SendBuffer
;------------------------------------------------
			mov RSI, [lpSocketIoData] 
			mov RBX, [RSI+PORT_IO_DATA.TotalBytes]
			mov RCX, [CountBytes]
			mov RAX, [TotalBytes]
			add RCX, RAX
			sub RBX, RAX
			mov [CountBytes], RCX
			mov [RSI+PORT_IO_DATA.CountBytes], RCX
			mov [RSI+PORT_IO_DATA.TotalBytes], RBX

			or RBX, RBX
			jnz jmpSendBytes@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
jmpCloseSend@Router:
				param 1, [RSI+PORT_IO_DATA.hFile]
				xor RAX, RAX
				mov [RSI+PORT_IO_DATA.hFile], RAX
				call [CloseHandle]

				mov DL, SRV_ERR_ReadClose
				or EAX, EAX
				jz jmpCloseSocket@Router

					mov RSI, [lpSocketIoData] 
					xor RAX, RAX
					mov [RSI+PORT_IO_DATA.hFile], RAX
					mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

jmpSendBytes@Router:
			mov RCX, [CountBytes]
;------------------------------------------------
;       * * *  Sending
;------------------------------------------------
jmpSending@Router:
	mov RAX, [ServerConfig.MaxSendSize]
	cmp RCX, RAX
	jb jmpSizeSend@Router
		mov RCX, RAX

jmpSizeSend@Router:
	mov [RSI+PORT_IO_DATA.WSABuffer.len], RCX
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
	add [RSI+PORT_IO_DATA.CountBytes], RCX

	mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
	mov R8,  [RSI+PORT_IO_DATA.CountBytes]
	cmp R8,  [ServerConfig.MaxRecvBufferSize]
	ja jmpWriteFile@Router
	
	cmp R8, RAX
	jb jmpReceiving@Router
;------------------------------------------------
;       * * *  Write File
;------------------------------------------------
jmpWriteFile@Router:
		xor RAX, RAX
		mov [RSI+PORT_IO_DATA.CountBytes], RAX
		param 5, RAX
		param 4, TotalBytes
		lea RDX, [RSI+PORT_IO_DATA.Buffer]
		param 1, [RSI+PORT_IO_DATA.hFile]
		mov [RSI+PORT_IO_DATA.WSABuffer.buf], RDX
		call [WriteFile]

		mov DL, SRV_ERR_WriteFile
		or EAX, EAX
		jz jmpCloseSocket@Router
;------------------------------------------------
;       * * *  Reset Buffer
;------------------------------------------------
			mov RSI, [lpSocketIoData] 
			mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
			sub RAX, [TotalBytes]
			js jmpSaveSize@Router
;------------------------------------------------
;       * * *  Close File
;------------------------------------------------
				mov [RSI+PORT_IO_DATA.TotalBytes], RAX
				or RAX, RAX
				jnz jmpReceiving@Router
jmpRecvClose@Router:
					param 1, [RSI+PORT_IO_DATA.hFile]
					call [CloseHandle]
					mov DL, SRV_ERR_SaveClose
					or EAX, EAX
					jz jmpCloseSocket@Router

						mov RSI, [lpSocketIoData]
						xor RAX, RAX
						mov [RSI+PORT_IO_DATA.hFile], RAX

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
	add [RSI+PORT_IO_DATA.CountBytes], RCX

	mov  DL, SRV_ERR_RecvSize
	mov RAX, [RSI+PORT_IO_DATA.TotalBytes]
	mov RCX, [RSI+PORT_IO_DATA.CountBytes]
	cmp RCX, RAX
	je jmpMethodToProcess@Router
	ja jmpPostError@Router
;------------------------------------------------
;       * * *  Receiving
;------------------------------------------------
jmpReceiving@Router:
	mov RSI, [lpSocketIoData] 
	mov RCX, [ServerConfig.MaxRecvSize]
	cmp RAX, RCX
	jb jmpSizeRecv@Router
		mov RAX, RCX

jmpSizeRecv@Router:
	mov [RSI+PORT_IO_DATA.WSABuffer.len], RAX
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

	mov RSI, [lpSocketIoData]
	mov RDI, [RSI+PORT_IO_DATA.TablePort]
	xor RAX, RAX
	mov [RDI], RAX

	mov  AL, SD_BOTH
	param 2, RAX
	param 1, [RSI+PORT_IO_DATA.Socket]
	mov [hFile], RCX

	call [shutdown]
	or EAX, EAX
	jz jmpSocket@Router

		mov  DL, SRV_ERR_ShutDown
		call PostReport

jmpSocket@Router:
	param 1, [hFile]
	call [closesocket]
	or EAX, EAX
	jz jmpCloseFile@Router

		mov  DL, SRV_ERR_SocketClose
		call PostReport
;------------------------------------------------
;       * * *  Close ReadFile / WriteFile
;------------------------------------------------
jmpCloseFile@Router:
	mov RSI, [lpSocketIoData]
	mov RCX, [RSI+PORT_IO_DATA.hFile]
	jRCXz jmpSocketFree@Router

		call [CloseHandle]

jmpSocketFree@Router:
	mov DL, SRV_MSG_Close
	call PostReport

	param 1, [lpSocketIoData]
	param 2, 0
	param 3, MEM_RELEASE
	call [VirtualFree]
	jmp jmpWaitCompletionPort@Router
;------------------------------------------------
;       * * *  End Thread  * * *
;------------------------------------------------
jmpEnd@Router:
	xor RAX, RAX
	param 1, RAX
	mov [ThreadSocketCtrl], EAX
	mov AL,  64
	add RSP, RAX
	call [ExitThread]
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------