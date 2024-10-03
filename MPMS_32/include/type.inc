;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	RESURSE: Structures + DataType
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;       * * *  DataType
;------------------------------------------------
BYTE					equ db
WORD					equ dw
DWORD					equ dd
QWORD					equ qd
PCHAR					equ dd

LPVOID					equ dd
HANDLE					equ dd
SOCKET					equ dd
LPHANDLE				equ dd
WSAEVENT				equ dd
SERVICE_STATUS_HANDLE	equ dd

STARTUPINFO_SIZE			equ 72
STARTUPINFO_COUNT			equ 18
PROCESS_INFORMATION_COUNT		equ  4
SOCKADDR_IN_SIZE			equ 16
MAXIMUM_WAIT_OBJECTS			equ 64
MAX_URL_SIZE				equ 1024
;------------------------------------------------
;       * * *  SERVICE_STATUS  * * *
;------------------------------------------------
struct SERVICE_STATUS
	dwServiceType			dd ?
	dwCurrentState			dd ?
	dwControlsAccepted		dd ?
	dwWin32ExitCode			dd ?
	dwServiceSpecificExitCode	dd ?
	dwCheckPoint			dd ?
	dwWaitHint			dd ?
ends

LPSERVICE_STATUS			equ LPVOID
SERVICE_STATUS_SIZE			equ 28
SERVICE_STATUS_COUNT			equ  7
;------------------------------------------------
;       * * *  SECURITY_ATTRIBUTES  * * *
;------------------------------------------------
struct SECURITY_ATTRIBUTES
	nLength				dd ?
	lpSecurityDescriptor		dd ?
	bInheritHandle			dd ?
ends

LPSECURITY_ATTRIBUTES	equ LPVOID
SECURITY_ATTRIBUTES_SIZE		equ 12
;------------------------------------------------
;       * * *  WSABUF  * * *
;------------------------------------------------
struct WSABUF
	len				dd ?
	buf				dd ?
ends

LPWSABUF				equ LPVOID
WSABUF_SIZE				equ 8
;------------------------------------------------
;       * * *  WSAOVERLAPPED  * * *
;------------------------------------------------
struct WSAOVERLAPPED
	Internal			dd ?
	InternalHigh			dd ?
	OffsetLow			dd ?
	OffsetHigh			dd ?
	hEvent				dd ?
ends

LPWSAOVERLAPPED				equ LPVOID
WSAOVERLAPPED_SIZE			equ 20
;------------------------------------------------
;       * * *  WSANETWORKEVENTS  * * *
;------------------------------------------------
struct WSANETWORKEVENTS
	lNetworkEvents			dd ?
	iErrorCode			dd 10 dup(?)
ends

LPWSANETWORKEVENTS			equ LPVOID
WSANETWORKEVENTS_SIZE	equ 44
;------------------------------------------------
;       * * *  SERVER_CONFIG  * * *
;------------------------------------------------
struct SERVER_CONFIG
	MaxRecvBufferSize		dd ?
	MaxReportStack			dd ?
	MaxConnections			dd ?
;	MaxRunning			dd ?
	MaxTimeOut			dd ?
	MaxBufferSize			dd ?
	MaxHeadSize			dd ?
	MaxRecvSize			dd ?
	MaxSendSize			dd ?
	MaxPipeSize			dd ?
	lpReportPath			dd ?
ends

LPSERVER_CONFIG				equ LPVOID
SERVER_CONFIG_SIZE			equ 44
SERVER_CONFIG_COUNT			equ 10
SERVER_CONFIG_PARAM			equ  9
SERVER_CONFIG_DWORD			equ  8
;------------------------------------------------
;       * * *  ASK_METHOD  * * *
;------------------------------------------------
struct ASK_METHOD
	Method				dd ?
	Directory			dd ?
;	Environ				dd ?
	RunPath				dd ?
	CmdLine				dd ?
	hProcess			dd ?
ends

LPASK_METHOD				equ LPVOID
ASK_METHOD_SIZE				equ 20
ASK_METHOD_COUNT			equ  5
ASK_METHOD_PARAM			equ  5
;------------------------------------------------
;       * * *  NET_HOST  * * *
;------------------------------------------------
struct NET_HOST
	Name				dd ?
	Address				dd ?
	hProcess			dd ?
	Reserved			dd ?
ends

LPNET_HOST				equ LPVOID
NET_HOST_SIZE				equ  16
NET_HOST_COUNT				equ   4
NET_HOST_PARAM				equ   3
;------------------------------------------------
;       * * *  PORT_IO_DATA  * * *
;------------------------------------------------
struct PORT_IO_DATA
	Overlapped			WSAOVERLAPPED ?
	WSABuffer			WSABUF ?
	TimeLimit			dd ?
	TablePort			dd ?
	NetHost				dd ?
	Socket				dd ?
	Address				dd ?
	Method				dd ?
	TransferredBytes		dd ?
	ExitCode			dd ?
	Connection			dw ?
	Route				dw ?
	hProcess			dd ?
	hFile				dd ?
	TotalBytes			dd ?
	CountBytes			dd ?
	Buffer				dd ?
ends

LPPORT_IO_DATA				equ LPVOID
PORT_DATA_SIZE				equ 84   ;   28 + 60
PORT_DATA_COUNT				equ 21   ;    7 + 14
PORT_CLEAR_COUNT			equ  8
;PORT_INIT_COUNT			equ ACCEPT_HEADER_COUNT
;------------------------------------------------
;       * * *  REPORT_HEADER  * * *
;------------------------------------------------
struct REPORT_HEADER
	Index				dd ?
	Error				dd ?
ends

LPREPORT_HEADER				equ LPVOID
REPORT_HEADER_SIZE			equ  8
REPORT_HEADER_COUNT			equ  2
;------------------------------------------------
;       * * *  REPORT_INFO  * * *
;------------------------------------------------
struct REPORT_INFO
	Index				dd ?
	Error				dd ?
	NetHost				dd ?
	Socket				dd ?
	Address				dd ?
	Method				dd ?
	TransferredBytes		dd ?
	ExitCode			dd ?
ends

LPREPORT_INFO				equ LPVOID
REPORT_INFO_SIZE			equ 32
REPORT_INFO_COUNT			equ  8
REPORT_INFO_PORT 			equ  6
;------------------------------------------------
;       * * *  ACCEPT_HEADER  * * *
;------------------------------------------------
struct ACCEPT_HEADER
	TimeLimit			dd ?
	TablePort			dd ?
	NetHost				dd ?
	Socket				dd ?
	Address				dd ?
ends

LPACCEPT_HEADER				equ LPVOID
ACCEPT_HEADER_SIZE			equ 20
ACCEPT_HEADER_COUNT			equ  5
ACCEPT_HEADER_REPORT			equ  5
ACCEPT_HEADER_CLEAR			equ  3
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
