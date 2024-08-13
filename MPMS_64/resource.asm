;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	MAIN: Init Resource
;	ver.1.75 (x64)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;section '.code' code readable executable
;------------------------------------------------
;   * * *  Includes System Modules
;------------------------------------------------
include 'proc\string.asm'
include 'proc\report.asm'
include 'proc\config.asm'

include 'thread\service.asm'
include 'thread\listen.asm'
include 'thread\route.asm'
include 'thread\process.asm'
;------------------------------------------------
;   * * *  Import Library Procedures * * *
;------------------------------------------------
section '.idata' import data readable writeable

DD 0,0,0,  RVA szKernel32,		RVA LibraryKernel32
DD 0,0,0,  RVA szWinSocket2,	RVA LibraryWinSocket2
DD 0,0,0,  RVA szAdvAPI32,		RVA LibraryAdvAPI32
DD 0,0,0,0,0
;------------------------------------------------
;   * * *  Import Table Kernel32 * * *
;------------------------------------------------
LibraryKernel32:

GetLastError				DQ RVA szGetLastError
VirtualAlloc				DQ RVA szVirtualAlloc
VirtualFree					DQ RVA szVirtualFree
GetTickCount				DQ RVA szGetTickCount
GetLocalTime				DQ RVA szGetLocalTime
GetSystemTime				DQ RVA szGetSystemTime 
GetCommandLine				DQ RVA szGetCommandLine
LoadLibrary					DQ RVA szLoadLibrary
GetProcAddress				DQ RVA szGetProcAddress
CreateIoCompletionPort		DQ RVA szCreateIoCompletionPort
GetQueuedCompletionStatus	DQ RVA szGetQueuedCompletionStatus
PostQueuedCompletionStatus	DQ RVA szPostQueuedCompletionStatus
SetHandleInformation		DQ RVA szSetHandleInformation
CloseHandle					DQ RVA szCloseHandle
Sleep						DQ RVA szSleep
CreateEvent					DQ RVA szCreateEvent
SetEvent					DQ RVA szSetEvent
CreateThread				DQ RVA szCreateThread
ExitThread					DQ RVA szExitThread
CreateProcess				DQ RVA szCreateProcess
ExitProcess					DQ RVA szExitProcess
GetExitCodeProcess			DQ RVA szGetExitCodeProcess
WaitForMultipleObjects		DQ RVA szWaitForMultipleObjects
TerminateProcess			DQ RVA szTerminateProcess
CreatePipe					DQ RVA szCreatePipe
CreateFile					DQ RVA szCreateFile
GetFileSizeEx				DQ RVA szGetFileSizeEx
ReadFile					DQ RVA szReadFile
WriteFile					DQ RVA szWriteFile
EndTableKernel32			DQ NULL
;------------------------------------------------
;   * * *  Import Table WinSocket2 * * *
;------------------------------------------------
LibraryWinSocket2:

setsockopt					DQ RVA szSetSockOpt
bind						DQ RVA szBinding
listen						DQ RVA szListen
shutdown					DQ RVA szShutdown
closesocket					DQ RVA szCloseSocket
WSAStartup					DQ RVA szWSAStartup
WSAGetLastError				DQ RVA szWSAGetLastError
WSACreateEvent				DQ RVA szWSACreateEvent
WSAEnumNetworkEvents		DQ RVA szWSAEnumNetworkEvents
WSAWaitForMultipleEvents	DQ RVA szWSAWaitForMultipleEvents
WSAEventSelect				DQ RVA szWSAEventSelect
WSACloseEvent				DQ RVA szWSACloseEvent
WSASocket					DQ RVA szWSASocket
WSAAccept					DQ RVA szWSAAccept
WSASend						DQ RVA szWSASend
WSARecv						DQ RVA szWSARecv
WSACleanup					DQ RVA szWSACleanup
EndTableWinSocket2			DQ NULL
;------------------------------------------------
;   * * *  Import Table AdvAPI32 * * *
;------------------------------------------------
LibraryAdvAPI32:

SetServiceStatus			DQ RVA szSetServiceStatus
RegisterServiceCtrlHandler	DQ RVA szRegisterServiceCtrlHandler
StartServiceCtrlDispatcher	DQ RVA szStartServiceCtrlDispatcher
EndTableAdvAPI32			DQ NULL
;------------------------------------------------
;   * * *  Init Service Dispacher  * * *
;------------------------------------------------
ServiceTable				DQ szServiceName, ServiceMain, NULL, NULL
SizeOfAddrIn				DQ SOCKADDR_IN_SIZE
;------------------------------------------------
;       * * *  WinAPI ProcNames
;------------------------------------------------
szKernel32					DB 'KERNEL32.DLL',0
szAdvAPI32					DB 'ADVAPI32.DLL',0
szWinSocket2				DB 'WS2_32.DLL',0
szServiceName				DB 'AntXServer',0

szGetLastError				DB 0,0, 'GetLastError',0
szVirtualAlloc				DB 0,0, 'VirtualAlloc',0
szVirtualFree				DB 0,0, 'VirtualFree',0
szGetTickCount				DB 0,0, 'GetTickCount',0
szGetLocalTime				DB 0,0, 'GetLocalTime',0
szGetSystemTime				DB 0,0, 'GetSystemTime',0
szGetCommandLine			DB 0,0, 'GetCommandLineA',0
szLoadLibrary				DB 0,0, 'LoadLibraryA',0
szGetProcAddress			DB 0,0, 'GetProcAddress',0
szCreateIoCompletionPort	DB 0,0, 'CreateIoCompletionPort',0
szGetQueuedCompletionStatus	DB 0,0, 'GetQueuedCompletionStatus',0
szPostQueuedCompletionStatus	DB 0,0, 'PostQueuedCompletionStatus',0
szSetHandleInformation		DB 0,0, 'SetHandleInformation',0
szCloseHandle				DB 0,0, 'CloseHandle',0
szSleep						DB 0,0, 'Sleep',0
szCreateEvent				DB 0,0, 'CreateEventA',0
szSetEvent					DB 0,0, 'SetEvent',0
szCreateThread				DB 0,0, 'CreateThread',0
szExitThread				DB 0,0, 'ExitThread',0
szCreateProcess				DB 0,0, 'CreateProcessA',0
szExitProcess				DB 0,0, 'ExitProcess',0
szGetExitCodeProcess		DB 0,0, 'GetExitCodeProcess',0
szWaitForMultipleObjects	DB 0,0, 'WaitForMultipleObjects',0
szTerminateProcess			DB 0,0, 'TerminateProcess',0
szCreatePipe				DB 0,0, 'CreatePipe',0
szCreateFile				DB 0,0, 'CreateFileA',0
szGetFileType				DB 0,0, 'GetFileType',0
szGetFileSizeEx				DB 0,0, 'GetFileSizeEx',0
szReadFile					DB 0,0, 'ReadFile',0
szWriteFile					DB 0,0, 'WriteFile',0

szSetSockOpt				DB 0,0, 'setsockopt',0
szBinding					DB 0,0, 'bind',0
szListen					DB 0,0, 'listen',0
szShutdown					DB 0,0, 'shutdown',0
szCloseSocket				DB 0,0, 'closesocket',0
szWSAStartup				DB 0,0, 'WSAStartup',0
szWSAGetLastError			DB 0,0, 'WSAGetLastError',0
szWSACreateEvent			DB 0,0, 'WSACreateEvent',0
szWSAEnumNetworkEvents		DB 0,0, 'WSAEnumNetworkEvents',0
szWSAWaitForMultipleEvents	DB 0,0, 'WSAWaitForMultipleEvents',0
szWSAEventSelect			DB 0,0, 'WSAEventSelect',0
szWSACloseEvent				DB 0,0, 'WSACloseEvent',0
szWSASocket					DB 0,0, 'WSASocketA',0
szWSAAccept					DB 0,0, 'WSAAccept',0
szWSASend					DB 0,0, 'WSASend',0
szWSARecv					DB 0,0, 'WSARecv',0
szWSACleanup				DB 0,0, 'WSACleanup',0

szSetServiceStatus				DB 0,0, 'SetServiceStatus',0
szRegisterServiceCtrlHandler	DB 0,0, 'RegisterServiceCtrlHandlerA',0
szStartServiceCtrlDispatcher	DB 0,0, 'StartServiceCtrlDispatcherA',0
;------------------------------------------------
;   * * *  ConfigParamWords
;------------------------------------------------
sServerConfigParam            DB 7,'Include',5,'Stack',7,'Connect',4,'Time',6,'Buffer',6, 'Header',4,'Recv',4,'Send',4,'Pipe',6,'Report'
sMethodParam                  DB 3,'Ask',3,'Dir',3,'Run',3,'Cmd',3,'Get'
sHostPathParam                DB 4,'Host',7,'Address',6,'Accept',0,0
sHexScaleChar                 DB '0123456789ABCDEF'
;szNoneMethod                 DB 4, 'NONE'

FuckUp db 2,' -'
;------------------------------------------------
;       * * *  Init Server Params  * * *
;------------------------------------------------
section '.data' data readable writeable

sStrByteScale	DD MAX_INT_SCALE dup(?)
ServerTime		SYSTEMTIME ?
LocalTime		SYSTEMTIME ?

TotalHost		QWORD ?
TotalMethod		QWORD ?

GetMethod		LPASK_METHOD ?
SetMethod		LPASK_METHOD ?
GetNetHost		LPNET_HOST ?
pFind			PCHAR ?
;------------------------------------------------
;       * * *  Init Service DataSection
;------------------------------------------------
ThreadServerCtrl	DWORD ?
ThreadSocketCtrl	DWORD ?
ThreadListenCtrl	DWORD ?
ThreadProcessCtrl	DWORD ?

hFile			HANDLE ?
hFileReport		HANDLE ?
hPortIOSocket	HANDLE ?
hStatus			SERVICE_STATUS_HANDLE ?

SrvStatus		SERVICE_STATUS ?
dSecurity		SECURITY_ATTRIBUTES ?
Address			sockaddr_in ?
;------------------------------------------------
;       * * *  Init Config DataSection
;------------------------------------------------
SocketDataSize		QWORD ?
ServerResurseId		QWORD ?
SetOptionPort		QWORD ?
CountProcess		QWORD ?
PostBytes			QWORD ?
PipeBytes			QWORD ?
TotalBytes			QWORD ?
CountBytes			QWORD ?
TransBytes			QWORD ?
TransFlag			QWORD ?

ServerConfig		SERVER_CONFIG ?
lppReportMessages 	DD REPORT_MESSAGE_COUNT dup(?)
;------------------------------------------------
;       * * *  Init Table Buffer
;------------------------------------------------
GetMemoryBuffer:
TabSocketIoData		LPPORT_IO_DATA ?

TabListenReport		LPREPORT_INFO ?
GetListenReport		LPREPORT_INFO ?
SetListenReport		LPREPORT_INFO ?
MaxListenReport:

TabRouteReport		LPREPORT_INFO ?
GetRouteReport		LPREPORT_INFO ?
SetRouteReport		LPREPORT_INFO ?
MaxRouteReport:

TabQueuedProcess	LPPORT_IO_DATA ?
GetQueuedProcess	LPPORT_IO_DATA ?
SetQueuedProcess	LPPORT_IO_DATA ?
MaxQueuedProcess	LPPORT_IO_DATA ?
;------------------------------------------------
;       * * *  Init Report DataSection
;------------------------------------------------
lpFileReport	LPREPORT_INFO ?

ListenReport	ACCEPT_HEADER ?
RouterHeader	REPORT_HEADER ?

SystemReport	REPORT_INFO ?
RouterReport	REPORT_INFO ?
TimeOutReport	REPORT_INFO ?
;------------------------------------------------
;       * * *  Init Router DataSection
;------------------------------------------------
lpPortIoCompletion	LPVOID ?
lpSocketIoData		LPPORT_IO_DATA ?
TransferredBytes	QWORD ?
;------------------------------------------------
;       * * *  Init Listener DataSection
;------------------------------------------------
WSockVer		WSADATA ?
ListenEvent		WSANETWORKEVENTS ?

TabListenSocket	SOCKET   MAX_NET_HOST dup(?)
TabNetEvent		WSAEVENT MAX_NET_HOST dup(?)
TabNetHost		DB NET_HOST_SIZE * MAX_NET_HOST dup(?)
;------------------------------------------------
;       * * *  Init Method DataSection
;------------------------------------------------
TabLibrary		LPVOID MAX_LIBRARY dup(?)
;------------------------------------------------
;       * * *  Init Process DataSection
;------------------------------------------------
hInPipe			HANDLE ?
hOutPipe		HANDLE ?

StartRunInfo	STARTUPINFO ?
ProcRunInfo		PROCESS_INFORMATION ?

ErrAskMethod	ASK_METHOD ?
DefAskMethod	ASK_METHOD ?
TabAskMethod	DB ASK_METHOD_SIZE * MAX_ASK_METHOD dup(?)

RunProcessSocket	LPPORT_IO_DATA MAXIMUM_WAIT_OBJECTS dup(?)
RunProcessEvent		HANDLE MAXIMUM_WAIT_OBJECTS dup(?)
;------------------------------------------------
;       * * *  Init Buffers
;------------------------------------------------
TabConfig:
szFileName		DB MAX_PATH_SIZE dup(?)
szReportName	DB MAX_PATH_SIZE dup(?)
_DataBuffer_	DB CONFIG_BUFFER_SIZE dup(?)
szTextReport	DB REPORT_BUFFER_SIZE dup(?)

szHtmlFuckUp DB 256 dup(?)
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
