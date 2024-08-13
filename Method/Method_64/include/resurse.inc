;-----------------------------------------------
;   AntX Web Server x32: ver.1.75
;   RESURSE: Define Param + Headers
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;-----------------------------------------------
;       * * *  Set Date + Time of Report
;-----------------------------------------------
DELTA_ZERO_YEAR             equ  2000

MAX_INT_SCALE               equ  256   ;    REPORT_MESSAGE_COUNT
GET_DATE_REPORT             equ  17
REPORT_NAME_SIZE            equ  24    ;    17 + 2 + 5

SET_TIME_SEP1               equ   8
SET_TIME_SEP2               equ  11
SET_TIME_SEP3               equ  14

SET_YEAR_VALUE              equ   2
SET_MONTH_VALUE             equ   5
SET_DAY_VALUE               equ   8
SET_HOUR_VALUE              equ  11
SET_MINUTE_VALUE            equ  14
SET_SECOND_VALUE            equ  17
;-----------------------------------------------
;       * * *  HTTP Request Date  * * *
;-----------------------------------------------
SET_WEEK_HEADER             equ   8
SET_DAY_HEADER              equ  13
SET_MONTH_HEADER            equ  16
SET_YEAR_HEADER             equ  22
SET_HOUR_HEADER             equ  25
SET_MINUTE_HEADER           equ  28
SET_SECOND_HEADER           equ  31
;-----------------------------------------------
;       * * *  HTTP Request Method  * * *
;-----------------------------------------------
HTTP_200_OK                 equ   0
HTTP_201_CREATE             equ   4
HTTP_400_BAD_REQUEST        equ   8
HTTP_403_FORBIDDEN          equ  12
HTTP_404_NOT_FOUND          equ  16
HTTP_405_ALLOWED            equ   ?
HTTP_500_INTERNAL           equ  20
HTTP_501_NOT_IMPLEMENT      equ  24
HTTP_503_BUSY               equ  28
;-----------------------------------------------
;       * * *  Router Messages  * * *
;-----------------------------------------------
MSG_SET_INFORMATION         equ 128         ; Ввод параметры порта
MSG_GET_INFORMATION         equ 127         ; Вывод параметры порта

;MSG_NO_ERROR               equ 128         ; Вывод WSAGetLastError
;MSG_NO_INFORMATION         equ  64
;-----------------------------------------------
;       * * *  Service Errors
;-----------------------------------------------
REPORT_MESSAGE_COUNT        equ 83          ; Конец блока сообщений !
SYS_ERR_ConfigFile          equ  0

SYS_ERR_Dispatcher          equ  1
SYS_ERR_Register            equ  2
SYS_ERR_StartPending        equ  3
SYS_ERR_Start               equ  4
SYS_ERR_StopPending         equ  5
SYS_ERR_Stop                equ  6
;-----------------------------------------------
;       * * *  Socket Errors
;-----------------------------------------------
SYS_ERR_WSAversion          equ  7
SYS_ERR_Socket              equ  8
SYS_ERR_Option              equ  9
SYS_ERR_Binding             equ 10
SYS_ERR_Listen              equ 11
SYS_ERR_NetEvent            equ 12
SYS_ERR_SetEvent            equ 13
SYS_ERR_SocketPort          equ 14
SYS_ERR_ProcEvent           equ 15

SYS_ERR_ThreadRouter        equ 16
SYS_ERR_ThreadListen        equ 17
SYS_ERR_ThreadProcess       equ 18
;-----------------------------------------------
;       * * *  System Errors
;-----------------------------------------------
SYS_ERR_CommandLine         equ 19
SYS_ERR_TableBuffer         equ 20
;-----------------------------------------------
;       * * *  Config Errors
;-----------------------------------------------
CFG_ERR_Library             equ 21
CFG_ERR_Method              equ 22
CFG_ERR_SystemParam         equ 21
CFG_ERR_SystemValue         equ 22
CFG_ERR_HostParam           equ 23
CFG_ERR_HostValue           equ 24
;-----------------------------------------------
;       * * *  TimeOut (lpTimeIoData)
;-----------------------------------------------
SYS_ERR_TimeShutDown        equ 25
;-----------------------------------------------
;       * * *  Processes (lpProcIoData)

PRC_ERR_WaitProc            equ 26
PRC_ERR_ExitProc            equ 27
PRC_ERR_PipeSize            equ  ?
PRC_ERR_PipeRead            equ 29

PRC_ERR_PipeIn              equ 30
PRC_ERR_PipeOut             equ 31
PRC_ERR_PipeWrite           equ 32
PRC_ERR_RunProc             equ 33
PRC_ERR_EndProc             equ 34

SRV_ERR_SendPipe            equ 35
;-----------------------------------------------
;       * * *  Listen Errors (lpListIoData)
;-----------------------------------------------
NET_ERR_SocketMemory        equ 36    ;    for CloseListenPort
NET_ERR_FindSocket          equ 37
NET_ERR_PortSocket          equ 38
NET_ERR_SendListen          equ 39
NET_ERR_RecvHeader          equ 40    ;    end CloseListenPort

NET_ERR_WaitConnect         equ 41

NET_ERR_GetConnect          equ 42
NET_ERR_SetConnect          equ 43
NET_ERR_Accept              equ 44
;-----------------------------------------------
;       * * *  Router SendFile (lpSockIoData)
;-----------------------------------------------
SRV_ERR_WaitRoute           equ 45
SRV_ERR_RouteMode           equ  ?

SRV_ERR_FileAttributes      equ  ?
SRV_ERR_OpenFile            equ 48
SRV_ERR_OpenSize            equ  ?
SRV_ERR_ReadFile            equ 50
SRV_ERR_ReadSize            equ 51

SRV_ERR_SendRouter          equ 52
SRV_ERR_ReadClose           equ 53
;-----------------------------------------------
;       * * *  Router RecvFile (lpSockIoData)
;-----------------------------------------------
SRV_ERR_SaveFile            equ 54
SRV_ERR_WriteFile           equ 55
SRV_ERR_SaveSize            equ 56
SRV_ERR_SizeWrite           equ  ?
SRV_ERR_RecvSize            equ 58

SRV_ERR_RecvRouter          equ 59
SRV_ERR_SaveClose           equ 60
;-----------------------------------------------
;       * * *  Router Errors
;-----------------------------------------------
SRV_ERR_SocketClose         equ 61
SRV_ERR_WriteClose          equ 62
SRV_ERR_ShutDown            equ 63

SRV_MSG_Send                equ 64
SRV_MSG_Recv                equ 65
SRV_MSG_Save                equ 66
;-----------------------------------------------
;       * * *  Server Connect
;-----------------------------------------------
SYS_MSG_Start               equ 67
SYS_MSG_Stop                equ 68
SYS_MSG_ShutDown            equ 69

SRV_MSG_Connected           equ 70
SRV_MSG_Disconnected        equ 71
SRV_MSG_BreakConnect        equ 72
SRV_MSG_TimeOut             equ 73
SRV_MSG_Close               equ 74
;-----------------------------------------------
;       * * *  Server Resurse
;-----------------------------------------------
SRV_ERR_Method              equ 75
SRV_ERR_Header              equ 76
SRV_ERR_Url                 equ 77
SRV_ERR_PathSize            equ 78
SRV_MSG_OpenAccess          equ 79
SRV_MSG_RecvDataSize        equ 80

NET_MSG_ConnectLimit        equ 81
SRV_MSG_ProcessLimit        equ 82

MSG_NO_ERROR                equ SRV_MSG_Send
MSG_NO_INFORMATION          equ SYS_MSG_Start
;-----------------------------------------------
;       * * *  Define Client Headers
;-----------------------------------------------
MAX_HEADER_LENGTH           equ 64          ; > 23
TABLE_HEADER_COUNT          equ 256         ; Количество HTTP-заголовков.
TABLE_HEADER_DEFAULT        equ  5          ; Количество HTTP-заголовков.

HEADER_Connection           equ  0          ; Сведения о проведении соединения. Connection: close, Keep-Alive
HEADER_Server               equ  1          ; Имя сервера.

HEADER_Content_Length       equ  2          ; Размер содержимого сущности в октетах (которые в русском языке обычно называют байтами). Content-Length: 1348
HEADER_Content_Type         equ  3          ; Формат и способ представления сущности. Content-Type: text/html;charset=utf-8
HEADER_Content_Disposition  equ  4          ; Способ распределения сущностей в сообщении при передаче нескольких фрагментов. Content-Disposition: form-data; name="AttachedFile1"; filename="photo-1.jpg"
HEADER_End                  equ  7

HEADER_Allow                equ  5          ; Принимаемые методы.
HEADER_Last_Modified        equ  6          ; Дата последней модификации сущности.
;-----------------------------------------------
;       * * *  Define Options
;-----------------------------------------------
TABLE_OPTION_SIZE           equ  4          ; Количество HTTP-заголовков.

OPTION_close                equ  1          ; Состояние соединения: закрытая передеча.
OPTION_keep_alive           equ  2          ; Состояние соединения: открытое соединение. 
OPTION_text_html            equ  3          ; Передача HTML контента.
OPTION_multipart            equ  4          ; Передача формы POST с файлами.
OPTION_text_plain           equ  5          ; Передача формы POST.
OPTION_form_urlencoded      equ  6          ; Передача однострочного POST '&'.
OPTION_inline               equ  7          ; Передача для отображения.
OPTION_attachment           equ  8          ; Передача для скачивания.
;-----------------------------------------------
;       * * *  Strings Params Of Environment
;-----------------------------------------------
REQUEST_METHOD              equ  0          ; Мы раньше говорили об этой переменной. Она содержит метод передачи данных шлюзу: GET или POST.
QUERY_STRING                equ  1          ; Содержит данные переданные через URL. Такие данные указываются после имени шлюза и знака ?.
SCRIPT_NAME                 equ  2          ; Содержит имя вызванного скрипта.

SERVER_SOFTWARE             equ  3          ; Название и версия программы сервера.
SERVER_NAME                 equ  4          ; Содержит IP адрес сервера или его доменное имя.
SERVER_PORT                 equ  5          ; Номер порта.

CONTENT_FILE                equ  6          ; Путь к файлу с полученными данными.
CONTENT_LENGTH              equ  7          ; Длинна переданной информации в байтах.

HEADER_SERVER_SIZE          equ  6          ; Длинна SERVER в байтах.
HEADER_CONNECTION_SIZE      equ 10          ; Длинна CONNECTION в байтах.
HEADER_TYPE_SIZE            equ 12          ; Длинна CONTENT_TYPE в байтах.
HEADER_LENGTH_SIZE          equ 14          ; Длинна CONTENT_LENGTH в байтах.
HEADER_DISPOSITION_SIZE     equ 19          ; Длинна CONTENT_DISPOSITION в байтах.
;-----------------------------------------------
;       * * *  END  * * *
;-----------------------------------------------
