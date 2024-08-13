;------------------------------------------------
;   AntX Web Server x64: ver.1.75
;   SYSTEM: HTTP Request
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpNotRespond		;	lpSocketIoData

	mov [lpSocketIoData], RCX
;	mov RSI, [lpSocketIoData]
	lea RDX, [RSI+PORT_IO_DATA.Buffer]
	mov RDI, RDX
	xor RCX, RCX
	mov EAX, END_CRLF
	stosd
;------------------------------------------------
;       * * *  Set Param
;------------------------------------------------
	mov RSI,[lpSocketIoData]
	mov [RSI+PORT_IO_DATA.TotalBytes], RCX
	mov [RSI+PORT_IO_DATA.Connection], CX
	mov RAX, RDI
	sub RAX, RDX
	mov [RSI+PORT_IO_DATA.CountBytes], RAX
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	ret
endp
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpPHPRespond		;	lpSocketIoData

	mov RSI, RCX 		;   lpSocketIoData
	mov RDI, MyMethod
	mov EAX, szMethod
	stosd
	mov EAX, szAskDir
	stosd
	mov EAX, szAskProc
	stosd
	xor EAX, EAX
	stosd
	mov EAX, httpGCIRequest
	stosd
	mov RSI,[lpSocketIoData]
	mov [RSI+PORT_IO_DATA.Route],  SET_PROC_BIT
	mov [RSI+PORT_IO_DATA.Method], MyMethod
	ret
endp
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpAcceptRespond	;	lpSocketIoData

	xor  RAX, RAX
	mov   AL, [HTTP_503]
	mov  RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.TotalBytes], RAX
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	xor  RAX, RAX

	param 3, RAX
	param 2, HTTP_503
	param 1, RSI
	call httpCreateHttpHeader

;   mov RBX, [lpSocketIoData]
	mov RSI, HTTP_503
	xor RAX, RAX
	lodsb
	mov RCX, RAX
	add [RBX+PORT_IO_DATA.CountBytes], RAX
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network GET Request  * * *
;------------------------------------------------
proc httpGETRequest		;	lpSocketIoData

	mov RDI, szFileName
	mov RSI, szHostPath
	xor RAX, RAX
	lodsb
	mov RCX, RAX
	rep movsb

	mov RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	lea RDX, [RSI+PORT_IO_DATA.Buffer+4]
;   param 2, [RSI+PORT_IO_DATA.CountBytes]
	param 1, RAX
	call httpGetURL

	cmp CL, 1
	jne jmpOpen@httpGETRequest

		mov RDI, MyMethod
		mov EAX, szMethod
		stosd
		mov EAX, szHostPath + 1
		stosd
		mov EAX, szFileName
		stosd
		xor EAX, EAX
		stosd
		mov EAX, httpGCIRequest
		stosd
		mov RSI,[lpSocketIoData]
		mov [RSI+PORT_IO_DATA.Route],  SET_PROC_BIT
		mov [RSI+PORT_IO_DATA.Method], MyMethod
		ret
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
jmpOpen@httpGETRequest:
	mov [Param], RCX
	xor RAX, RAX
	param 1, RAX
	param 6, FILE_ATTRIBUTE_READONLY
	param 5, OPEN_EXISTING
	param 4, RAX
	param 3, FILE_SHARE_READ
	param 2, GENERIC_READ
	param 1, szFileName
	call [CreateFile]

	cmp EAX, INVALID_HANDLE_VALUE
		je jmpError@httpGETRequest
;------------------------------------------------
;       * * *  Get FileSize
;------------------------------------------------
	mov RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.hFile], RAX
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_FILE

	param 1, ReadBytes
	param 2, RAX
	call [GetFileSizeEx]
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
	mov RSI, [lpSocketIoData]
	mov RAX, [ReadBytes]
	mov [RSI+PORT_IO_DATA.TotalBytes], RAX

	push [Param]
	push HTTP_200
	push RSI
	call httpCreateHttpHeader

;   mov RCX,  [Param]
;   call IntToStr
	ret
;------------------------------------------------
;       * * *  Open Error
;------------------------------------------------
jmpError@httpGETRequest:
	mov EDX, szFileName
	mov EDI, EDX
	mov ECX, MAX_PATH_SIZE
	xor EAX, EAX
	repnz scasb
;     jnz
	dec EDI
	mov EAX, '<br>'
	stosd

	mov RSI, HTTP_404
	xor EAX, EAX
	lodsb
	mov ECX, EAX
	rep movsb

	mov RSI, [lpSocketIoData]
	mov EAX, EDI
	sub EAX, EDX
	mov [RSI+PORT_IO_DATA.TotalBytes], RAX

	param 3, RCX
	param 2, HTTP_404
	param 1, RSI
	call httpCreateHttpHeader

;   mov RSI, [lpSocketIoData]
	mov RCX, [RSI+PORT_IO_DATA.TotalBytes]
	add [RSI+PORT_IO_DATA.CountBytes], RCX
	mov RSI, szFileName
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network POST Respond  * * *
;------------------------------------------------
proc httpPOSTRespond	;	lpSocketIoData

	mov RSI, [lpSocketIoData]
	mov  AX, [RSI+PORT_IO_DATA.Route]
	test AX, AX
	jnz jmpHeaders@httpPOSTRespond
;------------------------------------------------
;       * * *  Get Length
;------------------------------------------------
		mov RSI, [lpSocketIoData]
		mov RCX, [RSI+PORT_IO_DATA.CountBytes]
		lea RDI, [RSI+PORT_IO_DATA.Buffer]
		call HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Param
;------------------------------------------------
		mov RSI, [lpSocketIoData]
		mov [RSI+PORT_IO_DATA.TotalBytes], RAX
		mov [RSI+PORT_IO_DATA.Connection], CX
		mov [RSI+PORT_IO_DATA.Route], ROUTE_RECV_BUFFER

		mov RCX, [RSI+PORT_IO_DATA.CountBytes]
		cmp RAX, RCX
		jb  jmpError@httpPOSTRespond
		je  jmpHeaders@httpPOSTRespond
;		ja  jmpSet@httpPOSTRespond
;------------------------------------------------
;       * * *  Create Resourse
;------------------------------------------------
jmpSet@httpPOSTRespond:
		xor RAX, RAX
		param 1, RAX
		param 6, FILE_ATTRIBUTE_READONLY
		param 5, OPEN_EXISTING
		param 4, RAX
		param 3, FILE_SHARE_READ
		param 2, GENERIC_READ
		param 1, szFileName
		call [CreateFile]

		cmp EAX, INVALID_HANDLE_VALUE
		je jmpError@httpPOSTRespond

			mov RSI, [lpSocketIoData] 
			mov [RSI+PORT_IO_DATA.hFile], RAX
			mov [RSI+PORT_IO_DATA.Route], ROUTE_RECV_FILE
			ret
;------------------------------------------------
;       * * *  Open Error
;------------------------------------------------
jmpError@httpPOSTRespond:
	mov RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.TotalBytes], szTransferOk - szTransfer + szTransferEnd - szTransferError
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 
	xor RAX, RAX
	mov [RSI+PORT_IO_DATA.Connection],  AX

	param 3, RAX
	param 2, HTTP_501
	param 1, RSI
	call httpCreateHttpHeader

	mov ECX, szTransferError - szTransfer
	mov RSI, szTransfer
	rep movsb

;   mov RSI, [lpSocketIoData]
	mov RSI, szTransferOk - szTransfer + szTransferEnd - szTransferError
	add [RSI+PORT_IO_DATA.CountBytes], RCX
	mov RSI, szTransfer
	rep movsb
	ret
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
jmpHeaders@httpPOSTRespond:
	mov RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.TotalBytes], szTransferError - szTransfer
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 

	xor RAX, RAX
	param 3, RAX
	param 2, HTTP_201
	param 1, RSI
	call httpCreateHttpHeader

;   mov RSI, [lpSocketIoData]
	mov ECX, szTransferError - szTransfer
	add [RSI+PORT_IO_DATA.CountBytes], RCX
	mov RSI, szTransfer
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network CGI Request  * * *
;------------------------------------------------
proc httpGCIRequest lpSocketIoData

	mov RSI, [lpSocketIoData]
	mov  AX, [RSI+PORT_IO_DATA.Route]
	test AX, AX
	jnz jmpHeaders@httpGCIRequest

		mov [RSI+PORT_IO_DATA.Route], ROUTE_PROC_SEND
		mov ECX, 555
		ret
;------------------------------------------------
;       * * *  Get Size
;------------------------------------------------
jmpHeaders@httpGCIRequest:
;	mov RSI, [lpSocketIoData]
;   push ReadBytes
;   push [RSI+PORT_IO_DATA.hFile]
;	call [GetFileSizeEx]
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
;	mov RSI, [lpSocketIoData]
	add [RSI+PORT_IO_DATA.TotalBytes], szTransferResurse - szTransfer
	xor RAX, RAX
	param 3, RAX
	inc EAX
	mov [RSI+PORT_IO_DATA.Connection], AX
	param 2, HTTP_201
	param 1, RSI
	call httpCreateHttpHeader

;	mov RSI, [lpSocketIoData]
	mov RCX, szTransfer - szTransferResurse
	add [RSI+PORT_IO_DATA.CountBytes], RCX
	mov RSI, szTransferResurse
	rep movsb
	ret
;------------------------------------------------
;       * * *  Open Error
;------------------------------------------------
jmpError@httpGCIRequest:
	mov RSI, [lpSocketIoData]
	mov [RSI+PORT_IO_DATA.TotalBytes], szTransferError - szTransfer
	mov [RSI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 

	xor RAX, RAX
	mov [RSI+PORT_IO_DATA.Connection],  AX

	param 3, RAX
	param 2, HTTP_501
	param 1, RSI
	call httpCreateHttpHeader

	mov ECX, szTransferError - szTransfer
	mov RSI, szTransfer
	rep movsb

;	mov RSI, [lpSocketIoData]
	mov RCX, szTransfer - szTransferResurse
	mov [RSI+PORT_IO_DATA.CountBytes], RCX
	mov RSI, szTransferResurse
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------