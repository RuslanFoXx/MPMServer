;------------------------------------------------
;   AntX Web Server x32: ver.1.75
;   SYSTEM: HTTP Request
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;------------------------------------------------
;       * * *  Get Uniform Resource Locator  * * *
;------------------------------------------------
proc httpGetURL lpBuffer, CountBytes

;	mov EDI, szFileName + HOST_PATH
	mov ESI, [lpBuffer]
	mov ECX, [CountBytes]
	mov EBX, EDI

jmpScanUrl@httpGetURL:
;   mov AX, [ESI]
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
;       or AL, SET_CASE_DOWN
;       jmp jmpSetChar@httpGetURL
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
		or  AL, DL
		jmp jmpSetChar@httpGetURL
;------------------------------------------------
;       * * *  Set Path
;------------------------------------------------
jmpGetFolder@httpGetURL:
		mov AL, '\'

jmpGetExt@httpGetURL:
		mov EBX, EDI
		jmp jmpSetChar@httpGetURL
;------------------------------------------------
;       * * *  DefPage
;------------------------------------------------
jmpGetUrlSize@httpGetURL:
	mov [pBuffer], EBX
	mov ESI, EDI
	dec ESI
	lodsb
	cmp AL, '\'
	jne jmpUrlEnd@httpGetURL

		mov ESI, szSitePage
		add ECX, szHeaderTextHtml - szSitePage
		jmp jmpScanUrl@httpGetURL
;------------------------------------------------
;       * * *  Get URL Size
;------------------------------------------------
jmpUrlEnd@httpGetURL:
	xor EAX, EAX
	mov [EDI], AL

	mov EDX, EDI
	sub EDX, EBX
	mov ECX, ESI
;		jECXz jmpExtEnd@httpGetURL
;------------------------------------------------
;       * * *  Find Access
;------------------------------------------------
	mov ESI, szFileName
	sub ECX, ESI
	mov EAX, '\..\'

jmpScanAccess@httpGetURL:
	cmp EAX, [ESI]
;	je jmpAccessDenied@httpGetURL
	inc ESI
	loop jmpScanAccess@httpGetURL
;------------------------------------------------
;       * * *  Get RunProc
;------------------------------------------------
	dec EDX
	inc EBX
	mov ECX, EDX
	mov EDI, EBX

jmpScanExt@httpGetURL:
	mov AL, [EDI]
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
	mov ESI, TabExtType
	xor EAX, EAX
	mov ECX, EAX
	mov [Param], EAX

jmpFindExt@httpGetURL:
	inc [Param]
	add ESI, ECX
	xor EAX, EAX
	lodsb

	mov ECX, EAX
	jECXz jmpExtEnd@httpGetURL

		cmp EAX, EDX
		jne jmpFindExt@httpGetURL

			mov EDI, EBX
			repe cmpsb
			jne jmpFindExt@httpGetURL
				 mov ECX, [Param]

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
;   mov EDI, [lpBuffer]   ;   Init on the Top
;   mov ECX, [CountBytes]
	mov EDX, EDI
	mov [CountBytes], ECX

	xor EAX, EAX
	mov [Len], EAX

	inc EAX
	mov [Connection], EAX
	jmp jmpFindFirst@HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Connection
;------------------------------------------------
jmpGetConnect@HTTPRecvHeader:
	xor EAX, EAX
	mov [Connection], EAX
	jmp jmpFindEnd@HTTPRecvHeader
;------------------------------------------------
;       * * *  Set Length
;------------------------------------------------
jmpGetLength@HTTPRecvHeader:
	mov [Len], EDI
	jmp jmpFindEnd@HTTPRecvHeader
;------------------------------------------------
;       * * *  Scan Header
;------------------------------------------------
jmpScanHeader@HTTPRecvHeader:
	mov EBX, ECX
	mov EDX, EDI
	mov EAX,[EDI]
	cmp AX, CHR_CRLF
	je jmpEndHeader@HTTPRecvHeader
;------------------------------------------------
;       * * *  Get Ask Length
;------------------------------------------------
	xor ECX, ECX
	mov CL,  szHeaderConnection - szHeaderLength - 2
	mov ESI, szHeaderLength + 2
;   mov EDI, EDX
	repe cmpsb
	je jmpGetLength@HTTPRecvHeader
;------------------------------------------------
;       * * *  Get Ask Connection
;------------------------------------------------
;		xor ECX, ECX
		mov CL,  szKeepAlive - szHeaderConnection - 2
		mov ESI, szHeaderConnection + 2
		mov EDI, EDX
		repe cmpsb
		je jmpGetConnect@HTTPRecvHeader
;------------------------------------------------
;       * * *  Find End Header
;------------------------------------------------
jmpFindEnd@HTTPRecvHeader:
	mov ECX, EBX

jmpFindFirst@HTTPRecvHeader:
	mov EDI, EDX
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
	sub [CountBytes], ECX

	mov EAX, [Len]
	mov ECX, EAX
	jECXz jmpEnd@HTTPRecvHeader

		mov ESI, ECX
		call StrToWord

		inc EAX
		inc EAX
		add EAX, [CountBytes]
		mov ECX, [Connection]

jmpEnd@HTTPRecvHeader:
;   mov ECX, [Connection]
;	mov EAX, [CountBytes]
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------