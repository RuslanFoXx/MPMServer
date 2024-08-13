;------------------------------------------------
;   AntX Web Server x32: ver.1.75
;   SYSTEM: Headers
;   (c) Kyiv, Ruslan FoXx
;   10 May 2024
;------------------------------------------------
proc httpCreateHttpHeader lpSocketIoData, HeaderMethod, Content
;------------------------------------------------
;           * * *  Get Date + Time
;------------------------------------------------
	push ServerTime
	call [GetSystemTime]

	mov ESI, [lpSocketIoData]
	lea EDI, [ESI+PORT_IO_DATA.Buffer]
;	push EDI

	mov EAX, HEADER_HTTP
	stosd
	mov EAX, HEADER_HTTP_VER
	stosd
	mov AL, ' '
	stosb

	mov ESI, [HeaderMethod]
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
	mov ESI, ServerTime
	mov EBX, sStrByteScale + 2
	mov EAX, ECX
	lodsw
	sub AX, DELTA_ZERO_YEAR
	mov AX, [EBX+EAX*4]
	mov EDX, EAX

	mov EAX, ECX
	lodsw
	dec EAX
	mov EAX,1
	mov EAX, dword[sMonthDateHeader+EAX*4]
	push EAX
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

	pop EAX
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
	mov ESI, szHeaderType
	mov  CL, szHeaderDisposition - szHeaderType
	mov EBX, [Content]
	test BX, BX
	jz jmpTypeExt@Header

		mov CL, szHeaderTextHtml - szHeaderType
		rep movsb

;       dec EBX
		mov ESI, [TabFileTypeRequest-4+EBX*4]
		lodsb
		mov CL, AL
		rep movsb
;------------------------------------------------
;       * * *  Set Content Disposition
;------------------------------------------------
		cmp CL, [ESI]
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

	mov EBX, [lpSocketIoData]
	mov ECX, [EBX+PORT_IO_DATA.TotalBytes]
	call IntToStr
;------------------------------------------------
;       * * *  Set Connection
;------------------------------------------------
jmpHeaderConnect@Header:
	mov  CL, szClose - szHeaderConnection
	mov ESI, szHeaderConnection
	rep movsb

	mov EBX, [lpSocketIoData]
	mov  CL, szKeepAlive - szClose 
	mov  AX, [EBX+PORT_IO_DATA.Connection]
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

	mov ESI, EBX
	lea EDX, [ESI+PORT_IO_DATA.Buffer]
	mov [ESI+PORT_IO_DATA.WSABuffer.buf], EDX

	mov EAX, EDI
	sub EAX, EDX
	mov [ESI+PORT_IO_DATA.CountBytes], EAX

jmpEnd@Header:
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------