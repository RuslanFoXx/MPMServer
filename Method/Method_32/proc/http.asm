;------------------------------------------------
;   AntX Web Server x32: ver.1.75
;   SYSTEM: HTTP Request
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpNotRespond lpSocketIoData

	mov ESI, [lpSocketIoData]
	lea EDX, [ESI+PORT_IO_DATA.Buffer]
	mov EDI, EDX
	xor ECX, ECX
	mov EAX, END_CRLF
	stosd
;------------------------------------------------
;       * * *  Set Param
;------------------------------------------------
	mov ESI,[lpSocketIoData]
	mov [ESI+PORT_IO_DATA.TotalBytes], ECX
	mov [ESI+PORT_IO_DATA.Connection], CX
	mov EAX, EDI
	sub EAX, EDX
	mov [ESI+PORT_IO_DATA.CountBytes], EAX
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	ret
endp
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpPHPRespond lpSocketIoData

	mov EDI, MyMethod
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
	mov ESI,[lpSocketIoData]
	mov [ESI+PORT_IO_DATA.Route],  SET_PROC_BIT
	mov [ESI+PORT_IO_DATA.Method], MyMethod
	ret
endp
;------------------------------------------------
;       * * *  Network HTTP Request  * * *
;------------------------------------------------
proc httpAcceptRespond lpSocketIoData

	xor  EAX, EAX
	mov   AL, [HTTP_503]
	mov  ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.TotalBytes], EAX
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	xor  EAX, EAX
	push EAX
	push HTTP_503
	push ESI
	call httpCreateHttpHeader

;   mov EBX, [lpSocketIoData]
	mov ESI, HTTP_503
	xor EAX, EAX
	lodsb
	mov ECX, EAX
	add [EBX+PORT_IO_DATA.CountBytes], EAX
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network GET Request  * * *
;------------------------------------------------
proc httpGETRequest lpSocketIoData

	mov EDI, szFileName
	mov ESI, szHostPath
	xor EAX, EAX
	lodsb
	mov ECX, EAX
	rep movsb

	mov ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER
	lea EAX, [ESI+PORT_IO_DATA.Buffer+4]
	push [ESI+PORT_IO_DATA.CountBytes]
	push EAX
	call httpGetURL

	cmp CL, 1
	jne jmpOpen@httpGETRequest

		mov EDI, MyMethod
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
		mov ESI,[lpSocketIoData]
		mov [ESI+PORT_IO_DATA.Route],  SET_PROC_BIT
		mov [ESI+PORT_IO_DATA.Method], MyMethod
		ret
;------------------------------------------------
;       * * *  OpenFile
;------------------------------------------------
jmpOpen@httpGETRequest:
	mov [Param], ECX
	xor EAX, EAX
	push EAX
	push FILE_ATTRIBUTE_READONLY
	push OPEN_EXISTING
	push EAX
	push FILE_SHARE_READ
	push GENERIC_READ
	push szFileName
	call [CreateFile]

	cmp EAX, INVALID_HANDLE_VALUE
		je jmpError@httpGETRequest
;------------------------------------------------
;       * * *  Get FileSize
;------------------------------------------------
	mov ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.hFile], EAX
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_FILE

	push ReadBytes
	push EAX
	call [GetFileSizeEx]
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
	mov ESI, [lpSocketIoData]
	mov EAX, [ReadBytes]
	mov [ESI+PORT_IO_DATA.TotalBytes], EAX

	push [Param]
	push HTTP_200
	push ESI
	call httpCreateHttpHeader

;   mov ECX,  [Param]
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
;	jnz
	dec EDI
	mov EAX, '<br>'
	stosd

	mov ESI, HTTP_404
	xor EAX, EAX
	lodsb
	mov ECX, EAX
	rep movsb

	mov ESI, [lpSocketIoData]
	mov EAX, EDI
	sub EAX, EDX
	mov [ESI+PORT_IO_DATA.TotalBytes], EAX
	push ECX
	push HTTP_404
	push ESI
	call httpCreateHttpHeader

;   mov ESI, [lpSocketIoData]
	mov ECX, [ESI+PORT_IO_DATA.TotalBytes]
	add [ESI+PORT_IO_DATA.CountBytes], ECX
	mov ESI, szFileName
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network POST Respond  * * *
;------------------------------------------------
proc httpPOSTRespond lpSocketIoData

	mov ESI, [lpSocketIoData]
	mov  AX, [ESI+PORT_IO_DATA.Route]
	test AX, AX
	jnz jmpHeaders@httpPOSTRespond
;------------------------------------------------
;       * * *  Get Length
;------------------------------------------------
		mov ESI, [lpSocketIoData]
		mov ECX, [ESI+PORT_IO_DATA.CountBytes]
		lea EDI, [ESI+PORT_IO_DATA.Buffer]
		call HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Param
;------------------------------------------------
		mov ESI, [lpSocketIoData]
		mov [ESI+PORT_IO_DATA.TotalBytes], EAX
		mov [ESI+PORT_IO_DATA.Connection], CX
		mov [ESI+PORT_IO_DATA.Route], ROUTE_RECV_BUFFER

		mov ECX, [ESI+PORT_IO_DATA.CountBytes]
		cmp EAX, ECX
		jb  jmpError@httpPOSTRespond
		je  jmpHeaders@httpPOSTRespond
;		ja  jmpSet@httpPOSTRespond
;------------------------------------------------
;       * * *  Create Resourse
;------------------------------------------------
jmpSet@httpPOSTRespond:
		mov EDX, szFileResurse
		xor EAX, EAX
		push EAX
		push FILE_ATTRIBUTE_NORMAL
		push CREATE_ALWAYS
		push EAX
		push EAX
		push GENERIC_WRITE
		push EDX
		call [CreateFile]

		cmp EAX, INVALID_HANDLE_VALUE
		je jmpError@httpPOSTRespond

			mov ESI, [lpSocketIoData] 
			mov [ESI+PORT_IO_DATA.hFile], EAX
			mov [ESI+PORT_IO_DATA.Route], ROUTE_RECV_FILE
			ret
;------------------------------------------------
;       * * *  Open Error
;------------------------------------------------
jmpError@httpPOSTRespond:
	mov ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.TotalBytes], szTransferOk - szTransfer + szTransferEnd - szTransferError
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 
	xor EAX, EAX
	mov [ESI+PORT_IO_DATA.Connection],  AX
	push EAX
	push HTTP_501
	push ESI
	call httpCreateHttpHeader

	mov ECX, szTransferError - szTransfer
	mov ESI, szTransfer
	rep movsb

;   mov ESI, [lpSocketIoData]
	mov ECX, szTransferOk - szTransfer + szTransferEnd - szTransferError
	add [ESI+PORT_IO_DATA.CountBytes], ECX
	mov ESI, szTransfer
	rep movsb
	ret
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
jmpHeaders@httpPOSTRespond:
	mov ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.TotalBytes], szTransferError - szTransfer
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 

	xor EAX, EAX
	push EAX
	push HTTP_201
	push ESI
	call httpCreateHttpHeader

;   mov ESI, [lpSocketIoData]
	mov ECX, szTransferError - szTransfer
	add [ESI+PORT_IO_DATA.CountBytes], ECX
	mov ESI, szTransfer
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  Network CGI Request  * * *
;------------------------------------------------
proc httpGCIRequest lpSocketIoData

	mov ESI, [lpSocketIoData]
	mov  AX, [ESI+PORT_IO_DATA.Route]
	test AX, AX
	jnz jmpHeaders@httpGCIRequest

		mov [ESI+PORT_IO_DATA.Route], ROUTE_PROC_SEND
		mov ECX, 555
		ret
;------------------------------------------------
;       * * *  Get Size
;------------------------------------------------
jmpHeaders@httpGCIRequest:
;   mov ESI, [lpSocketIoData]
;   push ReadBytes
;   push [ESI+PORT_IO_DATA.hFile]
;   call [GetFileSizeEx]
;------------------------------------------------
;       * * *  Set Headers
;------------------------------------------------
;   mov ESI, [lpSocketIoData]
	add [ESI+PORT_IO_DATA.TotalBytes], szTransferResurse - szTransfer
	xor EAX, EAX
	push EAX
	inc EAX
	mov [ESI+PORT_IO_DATA.Connection], AX
;   push EAX
	push HTTP_201
	push ESI
	call httpCreateHttpHeader

;   mov ESI, [lpSocketIoData]
	mov ECX, szTransfer - szTransferResurse
	add [ESI+PORT_IO_DATA.CountBytes], ECX
	mov ESI, szTransferResurse
	rep movsb
	ret
;------------------------------------------------
;       * * *  Open Error
;------------------------------------------------
jmpError@httpGCIRequest:
	mov ESI, [lpSocketIoData]
	mov [ESI+PORT_IO_DATA.TotalBytes], szTransferError - szTransfer
	mov [ESI+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER 
	xor EAX, EAX
	mov [ESI+PORT_IO_DATA.Connection],  AX
	push EAX
	push HTTP_501
	push ESI
	call httpCreateHttpHeader

	mov ECX, szTransferError - szTransfer
	mov ESI, szTransfer
	rep movsb

;   mov ESI, [lpSocketIoData]
	mov ECX, szTransfer - szTransferResurse
	mov [ESI+PORT_IO_DATA.CountBytes], ECX
	mov ESI, szTransferResurse
	rep movsb
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------