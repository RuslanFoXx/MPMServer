;------------------------------------------------
;   AntX Web Server x64: ver.1.75
;   SYSTEM: Headers
;   (c) Kyiv, Ruslan FoXx
;   10 May 2024
;------------------------------------------------
proc httpCreateHttpHeader lpSocketIoData, HeaderMethod, Content
;------------------------------------------------
;           * * *  Get Date + Time
;------------------------------------------------
	param 1, ServerTime
	call [GetSystemTime]

	mov RSI, [lpSocketIoData]
	lea RDI, [RSI+PORT_IO_DATA.Buffer]
;	push EDI

	mov EAX, HEADER_HTTP
	stosd
	mov EAX, HEADER_HTTP_VER
	stosd
	mov AL, ' '
	stosb

	mov RSI, [HeaderMethod]
	xor EAX, EAX
	lodsb
	mov ECX, EAX
	rep movsb

	mov  CL, szHeaderType - szHeaderServer
	mov ESI, szHeaderServer
	rep movsb
;------------------------------------------------
;           * * *  Set Date = Www, DD Mmm YYYY
;------------------------------------------------
	mov RSI, ServerTime
	mov RBX, sStrByteScale + 2
	mov RSI, RSI
	lodsw
	sub AX, DELTA_ZERO_YEAR
	mov AX, [EBX+EAX*4]
	mov EDX, EAX

	mov EAX, ECX
	lodsw
	dec EAX
	mov EAX,1
	mov EAX, dword[sMonthDateHeader+EAX*4]
	mov R8d, EAX
	stosd

	mov EAX, ECX
	lodsw
	mov EAX,1
	mov EAX, dword[sWeekDateHeader+EAX*4]
	stosd

	mov CL, ' '
	mov EAX, ECX
	stosb

	lodsw
	mov AX, [EBX+EAX*4]
	stosw

	mov EAX, ECX
	stosb

	mov EAX, R8d
	stosd

	mov AX, '20'
	stosw

	mov EAX, EDX
	stosw
;------------------------------------------------
;           * * *  Set Time = hh:mm:ss
;------------------------------------------------
	mov EAX, ECX
	stosb

	lodsw
	mov AX, [EBX+EAX*4]
	stosw

	mov CL, ':'
	mov EAX, ECX
	stosb

	lodsw
	mov AX, [EBX+EAX*4]
	stosw

	mov EAX, ECX
	stosb

	lodsw
	mov AX, [EBX+EAX*4]
	stosw
;------------------------------------------------
;       * * *  Set Content Type
;------------------------------------------------
	mov RSI, szHeaderType
	mov  CL, szHeaderDisposition - szHeaderType
	mov RBX, [Content]
	test BX, BX
	jz jmpTypeExt@Header

		mov CL, szHeaderTextHtml - szHeaderType
		rep movsb

;       dec EBX
		mov RSI, [TabFileTypeRequest-4+EBX*4]
		lodsb
		mov CL, AL
		rep movsb
;------------------------------------------------
;       * * *  Set Content Disposition
;------------------------------------------------
		cmp CL, [RSI]
		je jmpContentLength@Header

			mov  CL, szHeaderLength - szHeaderDisposition
			mov ESI, szHeaderDisposition

jmpTypeExt@Header:
	rep movsb
;------------------------------------------------
;       * * *  Set Content Length
;------------------------------------------------
jmpContentLength@Header:
	mov CL,  szHeaderConnection - szHeaderLength
	mov ESI, szHeaderLength
	rep movsb

	mov RCX, [R15+PORT_IO_DATA.TotalBytes]
	call IntToStr
;------------------------------------------------
;       * * *  Set Connection
;------------------------------------------------
jmpHeaderConnect@Header:
	mov  CL, szClose - szHeaderConnection
	mov ESI, szHeaderConnection
	rep movsb

	mov  CL, szKeepAlive - szClose 
	mov  AX, [R15+PORT_IO_DATA.Connection]
	test AX, AX
	jz jmpEndHeader@Header

		mov  CL, szKeepAliveEnd - szKeepAlive
		mov ESI, szKeepAlive

jmpEndHeader@Header:
	rep movsb
;------------------------------------------------
;       * * *  End Header
;------------------------------------------------
	mov EAX, END_CRLF
	stosd

	lea RDX, [R15+PORT_IO_DATA.Buffer]
	mov [R15+PORT_IO_DATA.WSABuffer.buf], RDX

	mov RAX, RDI
	sub RAX, RDX
	mov [R15+PORT_IO_DATA.CountBytes], RAX

jmpEnd@Header:
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------