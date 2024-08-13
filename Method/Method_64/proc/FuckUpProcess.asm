proc FuckUpProcess

	mov RBX, RCX
	xor RAX, RAX
	mov RCX, RAX
	mov [RBX+PORT_IO_DATA.TotalBytes], RAX
	inc EAX
	mov [RBX+PORT_IO_DATA.Connection], AX

	lea RDI, [RBX+PORT_IO_DATA.Buffer]
	mov RSI, _DataHtmlText_
	mov R10, RDI
	mov  CX, _EndData_ - _DataHtmlText_
	rep movsb

	mov RSI, [RBX+PORT_IO_DATA.Method]
	mov RSI, [RSI]
	lodsb
	mov RCX, RAX
	rep movsb

	mov AL, '<'
	stosb
	mov EAX, '/H1>'
	stosd

	mov RAX, RDI
	sub RAX, R10
	mov [RBX+PORT_IO_DATA.CountBytes], RAX
	mov [RBX+PORT_IO_DATA.Route], ROUTE_SEND_BUFFER

;	invoke MessageBox, HWND_DESKTOP, R10, szServiceName, MB_OK
	ret

_DataHtmlText_:
	DB 'HTTP/1.1 501 Not Implemented', 13,10
	DB 'Server: AntX/1.75 x64'
	DB 'Date: Fri, 05 Jul 2024 07:46:36 GMT', 13,10
	DB 'Content-Type: text/html', 13,10
	DB 'Content-Length: 20', 13,10
	DB 'Connection: close', 13,10,13,10
	DB '<H1>Method: '
_EndData_:
endp