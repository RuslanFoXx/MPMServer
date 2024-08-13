;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	RESURSE: Define KeyWord Constants
;	ver.1.75 (x64)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;       * * *  Macros Param of Call
;------------------------------------------------
macro param n, expr
{
	if n in <0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16>
	if n eq 0
		if expr eq 0
			xor RAX, RAX
		else
			mov RAX, expr
		end if
	else if n eq 1
		if expr eq 0
			xor RCX, RCX
		else
			mov RCX, expr
		end if
	else if n eq 2
		if expr eq 0
			xor RDX, RDX
		else
			mov RDX, expr
		end if
	else if n eq 3
		if expr eq 0
			xor R8, R8
		else
			mov R8, expr
		end if
	else if n eq 4
		if expr eq 0
			xor R9, R9
		else
			mov R9, expr
		end if
	else
		mov qword [RSP+(n*8-8)], expr
	end if
	else
		display "parameter " #`n# " is not valid."
		param n, expr
  end if
}
;------------------------------------------------
;       * * *  DataType
;------------------------------------------------
BYTE					equ db
WORD					equ dw
DWORD					equ dd
QWORD					equ dq
PCHAR					equ dq

LPVOID					equ dq
HANDLE					equ dq
SOCKET					equ dq
LPHANDLE				equ dq
WSAEVENT				equ dq
SERVICE_STATUS_HANDLE	equ dq

STARTUPINFO_SIZE		equ 104
STARTUPINFO_COUNT		equ 13
PROCESS_INFORMATION_COUNT	equ  3
SOCKADDR_IN_SIZE		equ 16
MAXIMUM_WAIT_OBJECTS	equ 64
MAX_URL_SIZE			equ 1024
;------------------------------------------------
;       * * *  SERVICE_STATUS  * * *
;------------------------------------------------
struct SERVICE_STATUS
	dwServiceType		dd ?
	dwCurrentState		dd ?
	dwControlsAccepted	dd ?
	dwWin32ExitCode		dd ?
	dwServiceSpecificExitCode	dd ?
	dwCheckPoint		dd ?
	dwWaitHint			dd ?
ends

LPSERVICE_STATUS		equ LPVOID
SERVICE_STATUS_SIZE		equ 28
SERVICE_STATUS_COUNT	equ  7
;------------------------------------------------
;       * * *  SECURITY_ATTRIBUTES  * * *
;------------------------------------------------
struct SECURITY_ATTRIBUTES
	nLength				dq ?
	lpSecurityDescriptor	dq ?
	bInheritHandle		dq ?
ends

LPSECURITY_ATTRIBUTES	equ LPVOID
SECURITY_ATTRIBUTES_SIZE	equ 24
;------------------------------------------------
;       * * *  WSABUF  * * *
;------------------------------------------------
struct WSABUF
	len					dq ?
	buf					dq ?
ends

LPWSABUF				equ LPVOID
WSABUF_SIZE				equ 16
;------------------------------------------------
;       * * *  WSAOVERLAPPED  * * *
;------------------------------------------------
struct WSAOVERLAPPED
	Internal			dq ?
	InternalHigh		dq ?
	OffsetLow			dq ?
	OffsetHigh			dq ?
	hEvent				dq ?
ends

LPWSAOVERLAPPED			equ LPVOID
WSAOVERLAPPED_SIZE		equ 40
;------------------------------------------------
;       * * *  WSANETWORKEVENTS  * * *
;------------------------------------------------
struct WSANETWORKEVENTS
	lNetworkEvents		dd ?
	iErrorCode			dd 10 dup(?)
ends

LPWSANETWORKEVENTS		equ LPVOID
WSANETWORKEVENTS_SIZE	equ 44
;------------------------------------------------
;       * * *  SERVER_CONFIG  * * *
;------------------------------------------------
struct SERVER_CONFIG
	MaxRecvBufferSize	dq ?
	MaxReportStack		dq ?
	MaxConnections		dq ?
;	MaxRunning			dq ?
	MaxTimeOut			dq ?
	MaxBufferSize		dq ?
	MaxHeadSize			dq ?
	MaxRecvSize			dq ?
	MaxSendSize			dq ?
	MaxPipeSize			dq ?
	lpReportPath		dq ?
ends

LPSERVER_CONFIG			equ LPVOID
SERVER_CONFIG_SIZE		equ 80
SERVER_CONFIG_COUNT		equ 10
SERVER_CONFIG_PARAM		equ  9
SERVER_CONFIG_DWORD		equ  8

;------------------------------------------------
;       * * *  ASK_METHOD  * * *
;------------------------------------------------
struct ASK_METHOD
	Method				dq ?
	Directory			dq ?
;	Environ				dq ?
	RunPath				dq ?
	CmdLine				dq ?
	hProcess			dq ?
ends

LPASK_METHOD			equ LPVOID
ASK_METHOD_SIZE			equ 40
ASK_METHOD_COUNT		equ  5
ASK_METHOD_PARAM		equ  5
;------------------------------------------------
;       * * *  NET_HOST  * * *
;------------------------------------------------
struct NET_HOST
	Name				dq ?
	Address				dq ?
	hProcess			dq ?
 	Reserved			dq ?
ends

LPNET_HOST				equ LPVOID
NET_HOST_SIZE			equ  32
NET_HOST_COUNT			equ   4
NET_HOST_PARAM			equ   3
;------------------------------------------------
;       * * *  PORT_IO_DATA  * * *
;------------------------------------------------
struct PORT_IO_DATA
	Overlapped			WSAOVERLAPPED ?
	WSABuffer			WSABUF ?
	TimeLimit			dq ?
	TablePort			dq ?
	NetHost				dq ?
	Socket				dq ?
	Address				dq ?
	Method				dq ?
	TransferredBytes	dq ?
	ExitCode			dd ?
	Connection			dw ?
	Route				dw ?
	hProcess			dq ?
	hFile				dq ?
	TotalBytes			dq ?
	CountBytes			dq ?
	Buffer				dq ?
ends

LPPORT_IO_DATA              equ LPVOID
PORT_DATA_SIZE              equ 160  ;   56 + 108
PORT_DATA_COUNT             equ 20   ;    7 + 13
PORT_CLEAR_COUNT            equ  7
;PORT_INIT_COUNT            equ ACCEPT_HEADER_COUNT
;------------------------------------------------
;       * * *  REPORT_HEADER  * * *
;------------------------------------------------
struct REPORT_HEADER
	Index				dd ?
	Error				dd ?
ends

LPREPORT_HEADER			equ LPVOID
REPORT_HEADER_SIZE		equ  8
REPORT_HEADER_COUNT		equ  1
;------------------------------------------------
;       * * *  REPORT_INFO  * * *
;------------------------------------------------
struct REPORT_INFO
	Index				dd ?
	Error				dd ?
	NetHost				dq ?
	Socket				dq ?
	Address				dd ?,?
	Method				dq ?
	TransferredBytes	dq ?
	ExitCode			dd ?,?
ends

LPREPORT_INFO			equ LPVOID
REPORT_INFO_SIZE		equ 56
REPORT_INFO_COUNT		equ  7
REPORT_INFO_PORT 		equ  6
;------------------------------------------------
;       * * *  ACCEPT_HEADER  * * *
;------------------------------------------------
struct ACCEPT_HEADER
	TimeLimit			dq ?
;	TablePort			dq ?
	Index				dd ?
	Error				dd ?
	NetHost				dq ?
	Socket				dq ?
	Address				dd ?,?
ends

LPACCEPT_HEADER			equ LPVOID
ACCEPT_HEADER_SIZE		equ 48
ACCEPT_HEADER_COUNT		equ  5
ACCEPT_HEADER_REPORT	equ  5
ACCEPT_HEADER_CLEAR		equ  3
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
