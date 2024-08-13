;------------------------------------------------
;   AntX Web Server x32: ver.1.75
;   SYSTEM: Strings
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;------------------------------------------------
;       * * *  String To DWORD  * * *
;------------------------------------------------
proc StrToWord

;   mov RSI, RCX
;	mov RSI, Buffer
	xor RDX, RDX

	test RSI, RSI
	jz jmpEnd@StrToWord    ;   Error

	mov RCX, RDX
	mov RBX, RDX
	mov BL,  10

jmpScan@StrToWord:
	lodsb
	cmp AL, '0'
	jb jmpEnd@StrToWord

	cmp AL, '9' 
	ja jmpEnd@StrToWord

	sub AL, '0'
	mov CL, AL

	mov RAX, RDX
	mul RBX 
	add RAX, RCX
	mov RDX, RAX
	jmp jmpScan@StrToWord

jmpEnd@StrToWord:
	mov RAX, RDX   ;   for next char != 0
	ret
endp
;------------------------------------------------
;       * * *  String To HEX  * * *
;------------------------------------------------
proc StrToHex

;   mov RSI, RCX
;   mov RSI, Buffer
	xor RDX, RDX

jmpScan@StrToHex:
	xor RAX, RAX
	lodsb
	mov BL, '0'
	cmp AL, BL
	jb jmpEnd@StrToHex

	cmp AL, '9' 
	jbe jmpEnd@StrToHex

	cmp AL, 'A'
	jb jmpEnd@StrToHex

	mov BL, 'A' - 10
	cmp AL, 'F' 
	ja jmpEnd@StrToHex

jmpNext@StrToHex:
		sub AL, BL
		shl RDX, 4
		or  RDX, RAX
		jmp jmpScan@StrToHex

jmpEnd@StrToHex:
	ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc WordToStr

;	mov RSI, RDX
;	mov RSI, Buffer

	test RCX, RCX
	jns jmpSet@WordToStr

		mov AL, '-'
		stosb
		neg RCX

jmpSet@WordToStr:
	xor RBX, RBX
	mov BL,  10
	mov RAX, RCX

jmpScan@WordToStr:
	inc RDI
	xor RDX, RDX
	div RBX
	test RAX, RAX
	jnz jmpScan@WordToStr

	mov RSI, RDI
	mov [RDI], AL
	mov EAX, ECX

jmpDiv@WordToStr:
	dec RDI
	xor RDX, RDX
	div RBX

	add DL, '0'
	mov [RDI], DL

	test RAX, RAX
	jnz jmpDiv@WordToStr

	mov RDI, RSI 
	ret
endp
;------------------------------------------------
;       * * *  INT To String  * * *
;------------------------------------------------
proc IntToStr

;	mov EDI, pBuffer
;	mov ECX, Value
;	test ECX, ECX
;	jns jmpSign@IntToStr
;		neg ECX
;		mov AL, '-'
;		stosb

jmpSign@IntToStr:
	xor EBX, EBX
	mov BL,  10
	mov EAX, ECX

jmpScan@IntToStr:
	inc EDI
	xor EDX, EDX
	div EBX
	test EAX, EAX
	jnz jmpScan@IntToStr

	mov ESI, EDI
;   mov [EDI], AL
	mov EAX, ECX

jmpDiv@IntToStr:
	dec EDI
	xor EDX, EDX
	div EBX

	add DL, '0'
	mov [EDI], DL

	test EAX, EAX
	jnz jmpDiv@IntToStr

	mov EDI, ESI 
	xor ECX, ECX
	ret
endp
;------------------------------------------------
;
;       * * *  HEX To String  * * *
;
;------------------------------------------------
proc HexToStr

;   mov EDI, pBuffer
	mov ESI, sHexScaleChar
;   mov EDX, Value
	xor ECX, ECX
	mov EBX, ECX
	mov CL,  8

jmpScan@HexToStr:
	rol EDX, 4
	mov BL,  DL
	and BL,  0Fh
	mov AL, [ESI+EBX]
	stosb
	loop jmpScan@HexToStr

;   mov [RDI], CL
	ret
	sHexScaleChar DB "0123456789ABCDEF"
endp
;------------------------------------------------
;       * * *  HEX To String  * * *
;------------------------------------------------
proc HexToStr1

;   mov EDI, pBuffer
;   mov EDX, Value
	xor ECX, ECX
	mov CL, 8

jmpScan@HexToStr1:
	rol EDX, 4
	mov EAX, EDX
	and AL,  0Fh
	add AL,  30h  ;  '0'
	cmp AL,  3Ah  ;  '9' + 1
	jb jmpSet@HexToStr1
		add AL, 'A' - 3Ah

jmpSet@HexToStr1:
	stosb
	loop jmpScan@HexToStr1
;   mov [EDI], CL
	ret
endp
;------------------------------------------------
;       * * *  Get SocketTime  * * *
;------------------------------------------------
proc GetString

;   mov EDX, Buffer
;   mov EBX, String

jmpScanMessage@GetString:
	mov ESI, [EBX]
	test ESI, ESI
	jz jmpNextMessage@GetString

		push ECX

		mov EDI, EDX
		xor ECX, ECX
		mov CL, [ESI]
		inc ECX
		inc ECX
		rep movsb

		mov [EBX], EDX

		mov EDX, EDI
		pop ECX

jmpNextMessage@GetString:
	add EBX, 4
	loop jmpScanMessage@GetString
	ret
endp
;------------------------------------------------
;       * * *  Get Address (inet_addr+htons)
;------------------------------------------------
proc GetAddressPort

;   mov RSI, Address
	xor EBX, EBX
	mov ECX, EBX
	mov EDX, EBX
	mov  BL, 10

jmpFindAddr@GetAddressPort:
	push EDX
	xor EDI, EDI

jmpScanAddr@GetAddressPort:
	lodsb
	cmp AL, '0'
	jb jmpGetAddr@GetAddressPort

	cmp AL, '9' 
	ja jmpGetAddr@GetAddressPort

		sub AL, '0'
		mov CL, AL

		mov EAX, EDI
		mul EBX 
		add EAX, ECX
		mov EDI, EAX
		jmp jmpScanAddr@GetAddressPort

jmpGetAddr@GetAddressPort:
	pop EDX
	or  EDX, EDI
	ror EDX, 8 

	cmp AL, '.'
	je jmpFindAddr@GetAddressPort

	push EDX
	mov  EBX, 20480    ;     htons( 80 )
 
	cmp AL, ':'
	jne jmpEnd@GetAddressPort
;------------------------------------------------
;       * * *  Get Port (htons)
;------------------------------------------------
jmpScanPort@GetAddressPort:
		lodsb
		cmp AL, '0'
		jb jmpGetPort@GetAddressPort

		cmp AL, '9' 
		ja jmpGetPort@GetAddressPort

			sub AL, '0'
			mov CL, AL

			mov EAX, EDI
			mul EBX 
			add EAX, ECX
			mov EDI, EAX
			jmp jmpScanPort@GetAddressPort

jmpGetPort@GetAddressPort:
		xchg AH, AL    ;   htons
		mov EBX, EAX

jmpEnd@GetAddressPort:
;	mov EBX, Addr.sin_port
;   mov EAX, Addr.sin_addr.S_un.S_addr 
	pop EAX
	ret
endp
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
