;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	RESURSE: Define Param + Headers
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;       * * *  Service Errors
;------------------------------------------------
REPORT_MESSAGE_COUNT        equ 80
SYS_ERR_ConfigFile          equ  0

SYS_ERR_Dispatcher          equ  1
SYS_ERR_Register            equ  2
SYS_ERR_StartPending        equ  3
SYS_ERR_Start               equ  4
SYS_ERR_StopPending         equ  5
SYS_ERR_Stop                equ  6
;------------------------------------------------
;       * * *  Socket Errors
;------------------------------------------------
SYS_ERR_WSAversion          equ  7
SYS_ERR_Socket              equ  8
SYS_ERR_Option              equ  9
SYS_ERR_Binding             equ 10
SYS_ERR_Listen              equ 11
SYS_ERR_NetEvent            equ 12
SYS_ERR_SetEvent            equ 13
SYS_ERR_SocketPort          equ 14
SYS_ERR_ProcEvent           equ 15
SYS_ERR_HostProc            equ 16

SYS_ERR_ThreadRouter        equ 17
SYS_ERR_ThreadListen        equ 18
SYS_ERR_ThreadProcess       equ 19
;------------------------------------------------
;       * * *  System Errors
;------------------------------------------------
SYS_ERR_CommandLine         equ 20
SYS_ERR_TableBuffer         equ 21
;------------------------------------------------
;       * * *  Config Errors
;------------------------------------------------
CFG_ERR_Library             equ 22
CFG_ERR_Method              equ 23
CFG_ERR_SystemParam         equ 24
CFG_ERR_SystemValue         equ ?
CFG_ERR_HostParam           equ 26
CFG_ERR_HostValue           equ 27
;------------------------------------------------
;       * * *  TimeOut (lpTimeIoData)
;------------------------------------------------
SYS_ERR_TimeShutDown        equ 28
;------------------------------------------------
;       * * *  Processes (lpProcIoData)
;------------------------------------------------
PRC_ERR_WaitProc            equ 29
PRC_ERR_ExitProc            equ 30
PRC_ERR_PipeSize            equ 31
PRC_ERR_PipeRead            equ  ?

PRC_ERR_PipeIn              equ 33
PRC_ERR_PipeOut             equ 34
PRC_ERR_PipeWrite           equ 35
PRC_ERR_RunProc             equ 36
PRC_ERR_EndProc             equ 37

SRV_ERR_SendPipe            equ 38
SRV_ERR_RecvPipe            equ 39
;------------------------------------------------
;       * * *  Listen Errors (lpListIoData)
;------------------------------------------------
NET_ERR_SocketMemory        equ 40
NET_ERR_FindSocket          equ 41
NET_ERR_PortSocket          equ 42
NET_ERR_ListRecv            equ 43
NET_ERR_ListSend            equ 44

NET_ERR_WaitConnect         equ 45

NET_ERR_GetConnect          equ 46
NET_ERR_SetConnect          equ 47
NET_ERR_Accept              equ 48
;------------------------------------------------
;       * * *  Router SendFile (lpSockIoData)
;------------------------------------------------
SRV_ERR_WaitRoute           equ 49
SRV_ERR_RouteMode           equ  ?

SRV_ERR_ReadFile            equ 51
SRV_ERR_ReadSize            equ 52

SRV_ERR_SendRouter          equ 53
SRV_ERR_ReadClose           equ 54
;------------------------------------------------
;       * * *  Router RecvFile (lpSockIoData)
;------------------------------------------------
SRV_ERR_SaveFile            equ 55
SRV_ERR_WriteFile           equ 56
SRV_ERR_SaveSize            equ 57
SRV_ERR_SizeWrite           equ  ?
SRV_ERR_RecvSize            equ 59

SRV_ERR_RecvRouter          equ 60
SRV_ERR_SaveClose           equ 61
;------------------------------------------------
;       * * *  Router Errors
;------------------------------------------------
SRV_ERR_SocketClose         equ 62
SRV_ERR_ShutDown            equ 63

SRV_MSG_Send                equ 64
SRV_MSG_Recv                equ 65
SRV_MSG_Save                equ 66
;------------------------------------------------
;       * * *  Server Connect
;------------------------------------------------
SYS_MSG_Start               equ 67
SYS_MSG_Stop                equ 68
SYS_MSG_ShutDown            equ 69

SRV_MSG_Connected           equ 70
SRV_MSG_Disconnected        equ 71
SRV_MSG_BreakConnect        equ 72
SRV_MSG_TimeOut             equ 73
SRV_MSG_Close               equ 74
;------------------------------------------------
;       * * *  Server Resurse
;------------------------------------------------
SRV_MSG_Method              equ 75
SRV_MSG_OpenAccess          equ 76
SRV_MSG_RecvDataSize        equ 76

NET_MSG_ConnectLimit        equ 77
SRV_MSG_ProcessLimit        equ 78
;------------------------------------------------
MSG_NO_ERROR                equ SRV_MSG_Send
MSG_NO_INFORMATION          equ SYS_MSG_Start
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------
