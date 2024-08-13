;------------------------------------------------
;   AntX Web Server x64: ver.1.75
;   SYSTEM: HTTP Request
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;------------------------------------------------
;       * * *  Get Uniform Resource Locator  * * *
;------------------------------------------------
proc httpGetURL lpBuffer, CountBytes

;	mov RDI, szFileName + HOST_PATH
;	mov RCX, CountBytes
	mov RSI, RDX     ;    Buffer
	mov RDI, R8
	mov R10, R8

jmpScanUrl@httpGetURL:
	lodsb
	mov DL, ' '
	cmp AL, DL
	jbe jmpGetUrlSize@httpGetURL

		cmp AL, '?'
		je jmpGetUrlSize@httpGetURL

		cmp AL, '/'
		je jmpGetFolder@httpGetURL

;		cmp AL, '\'
;		je jmpGetFolder@httpGetURL

		cmp AL, '.'
		je jmpGetExt@httpGetURL

		cmp AL, '%'
		je jmpGetHex@httpGetURL

		cmp AL, '+'
		jne jmpSetChar@httpGetURL
			mov AL, DL
;------------------------------------------------
;       * * *  Set CharChange
;------------------------------------------------
jmpSetChar@httpGetURL:
	stosb
	loop jmpScanUrl@httpGetURL
	ret
;------------------------------------------------
;       * * *  Set CharDown
;------------------------------------------------
;jmpSetDown@httpGetURL:
;	or AL, SET_CASE_DOWN
;	jmp jmpSetChar@httpGetURL
;------------------------------------------------
;       * * *  Set HexChar
;------------------------------------------------
jmpGetHex@httpGetURL:
	lodsb
	cmp AL, '0'
	jb jmpSetChar@httpGetURL

	cmp AL, 'A'
	ja jmpSetChar@httpGetURL

	cmp AL, '9'
	jbe jmpSetHex1@httpGetURL
		sub AL, 'A' - '0' + 10

jmpSetHex1@httpGetURL:
	sub AL, '0'
	mov DL, AL

	dec ECX
	lodsb
	cmp AL, '0'
	jb jmpSetChar@httpGetURL

	cmp AL, 'A'
	ja jmpSetChar@httpGetURL

	cmp AL, '9'
	jbe jmpSetHex2@httpGetURL
		sub AL, 'A' - '0' + 10

jmpSetHex2@httpGetURL:
	sub AL, '0'
	shr AL, 4
	 or AL, DL
	jmp jmpSetChar@httpGetURL
;------------------------------------------------
;       * * *  Set Path
;------------------------------------------------
jmpGetFolder@httpGetURL:
	mov AL, '\'

jmpGetExt@httpGetURL:
	mov R10, RDI
	jmp jmpSetChar@httpGetURL
;------------------------------------------------
;       * * *  DefPage
;------------------------------------------------
jmpGetUrlSize@httpGetURL:
	mov RSI, RDI
	dec RSI
	lodsb
	cmp AL, '\'
	jne jmpUrlEnd@httpGetURL

		mov RSI, szSitePage
		add ECX, szHeaderTextHtml - szSitePage
		jmp jmpScanUrl@httpGetURL
;------------------------------------------------
;       * * *  Get URL Size
;------------------------------------------------
jmpUrlEnd@httpGetURL:
	xor EAX, EAX
	mov [RDI], AL
;------------------------------------------------
;       * * *  Find Access
;------------------------------------------------
	mov RCX, RDI
	sub RCX, R8
;	jECXz jmpExtEnd@httpGetURL

	mov RDX, RCX
	mov EAX, '\..\'

jmpScanAccess@httpGetURL:
	cmp EAX, [RSI]
;	je jmpAccessDenied@httpGetURL
	inc ESI
	loop jmpScanAccess@httpGetURL
;------------------------------------------------
;       * * *  Get RunProc
;------------------------------------------------
	dec EDX
	inc EBX
	mov ECX, EDX
	mov RDI, R10

jmpScanExt@httpGetURL:
	mov AL, [RDI]
	cmp AL, 'A'
	jb jmpNextExt@httpGetURL

	cmp AL, 'Z'
	ja jmpNextExt@httpGetURL
		or AL, SET_CASE_DOWN

jmpNextExt@httpGetURL:
	stosb
	loop jmpScanExt@httpGetURL
;------------------------------------------------
;       * * *  Find TableExt
;------------------------------------------------
	mov RSI, TabExtType
	xor RAX, RAX
	mov RCX, RAX

jmpFindExt@httpGetURL:
	add RSI, RCX
	xor EAX, EAX
	lodsb

	mov ECX, EAX
	jECXz jmpExtEnd@httpGetURL

		cmp EAX, EDX
		jne jmpFindExt@httpGetURL

			mov RDI, R10
			repe cmpsb
			jne jmpFindExt@httpGetURL

jmpExtEnd@httpGetURL:
	ret
endp
;------------------------------------------------
;       * * *  Network HTTP Request Headers * * *
;------------------------------------------------
proc HTTPRecvHeader  ;  lpBuffer, CountBytes
;------------------------------------------------
;       * * *  Get Headers
;------------------------------------------------
;	mov EDI, [lpBuffer]   ;   Init on the Top
;   mov ECX, [CountBytes]
	mov R15, RCX
	xor R9,  R9
	mov R10, R9
	inc R9d
	jmp jmpFindFirst@HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Connection
;------------------------------------------------
jmpGetConnect@HTTPRecvHeader:
	xor R9, R9
	jmp jmpFindEnd@HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Length
;------------------------------------------------
jmpGetLength@HTTPRecvHeader:
	mov R10, RDI
	jmp jmpFindEnd@HTTPRecvHeader
;------------------------------------------------
;       * * *  Scan Header
;------------------------------------------------
jmpScanHeader@HTTPRecvHeader:
	mov RBX, RCX
	mov RDX, RDI
	mov EAX,[RDI]
	cmp AX, CHR_CRLF
	je jmpEndHeader@HTTPRecvHeader
;------------------------------------------------
;       * * *  Get Ask Length
;------------------------------------------------
	xor RCX, RCX
	mov CL,  szHeaderConnection - szHeaderLength - 2
	mov ESI, szHeaderLength + 2
;	mov EDI, EDX
	repe cmpsb
	je jmpGetLength@HTTPRecvHeader
;------------------------------------------------
;       * * *  Get Ask Connection
;------------------------------------------------
	mov CL,  szKeepAlive - szHeaderConnection - 2
	mov ESI, szHeaderConnection + 2
	mov EDI, EDX
	repe cmpsb
	je jmpGetConnect@HTTPRecvHeader
;------------------------------------------------
;       * * *  Find End Header
;------------------------------------------------
jmpFindEnd@HTTPRecvHeader:
	mov RCX, RBX

jmpFindFirst@HTTPRecvHeader:
	mov RDI, RDX
	mov AL,  CHR_LF
	repne scasb
	je jmpScanHeader@HTTPRecvHeader
		xor EAX, EAX
		ret
;		jmp jmpSyntaxError@HTTPRecvHeader
;------------------------------------------------
;       * * *  Get Ask End
;------------------------------------------------
jmpEndHeader@HTTPRecvHeader:
	mov [R15+PORT_IO_DATA.Connection], R9w
	sub R11, RCX

	test R10, R10
	jz jmpEnd@HTTPRecvHeader

		mov RSI, R10
		sub R14, RCX
		call StrToWord

		inc RAX
		inc RAX
		add RAX, R14
		mov [R15+PORT_IO_DATA.TotalBytes], RAX

jmpEnd@HTTPRecvHeader:
;	mov ECX, [Connection]
;	mov EAX, [CountBytes]
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------