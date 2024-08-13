;------------------------------------------------
;   AntX Web Server x32: ver.1.74
;   MAIN: Define Memory
;   (c) Kyiv, Ruslan FoXx
;   01 April 2024
;------------------------------------------------
;   * * *  Include System Library
;          you can simply switch between win32ax, win32wx, win64ax and win64wx here
;------------------------------------------------
include 'win64a.inc'

include 'include\resurse.inc'
include 'include\const.inc'
include 'include\type.inc'
;------------------------------------------------
;       * * *  System Constant  * * *
;------------------------------------------------
SET_SERVICE_MODE          equ FALSE
SET_DEBUF_MODE            equ TRUE    ;   TRUE / FALSE

STACK_FRAME_SIZE          equ 0FFFFFh  ;   1MB all = 36184 
STACK_FRAME_CLEAR         equ ( TabRunProcess - ThreadServerCtrl ) / 4 + 1
;------------------------------------------------
;       * * *  Limit Constants
;------------------------------------------------
DELTA_ZERO_YEAR           equ  2000
MAX_INT_SCALE             equ  256

MAX_CONFIG_COUNT          equ  1024
MAX_PARAM_LENGTH          equ   255
EXT_TYPE_COUNT            equ  39

DATA_BUFFER_OFFSET        equ   256
CONFIG_BUFFER_SIZE        equ 16384
REPORT_BUFFER_SIZE        equ  2048    ;   2 * MAX_PATH_SIZE

MAX_PATH_SIZE             equ  1024
MAX_EXT_SIZE              equ  32
MAX_URL_SIZE              equ  2048
NET_MAX_FILE              equ 0FFFFFFFFh
LOG_MAX_FILE              equ 1000000

HTTP_HEADER_SIZE          equ  4096
NET_MIN_FRAME             equ   256
NET_MAX_FRAME             equ 16384
;------------------------------------------------
;       * * *  Socket Constants
;------------------------------------------------
MAX_NET_HOST              equ  MAXIMUM_WAIT_OBJECTS
MAX_NET_PROC              equ (MAXIMUM_WAIT_OBJECTS-1)
MAX_RUN_PROC              equ 255
MAX_ASK_METHOD            equ 255

MAX_LIBRARY               equ 64
MAX_PROCESS               equ 4096
MAX_SOCKET                equ 65535  ;  131072
MAX_REPORT                equ 16384

MAX_NET_TIMEOUT           equ 3600   ; sec !
WAIT_SERVICE_HINT         equ 5000
WAIT_LIST_TIMEOUT         equ 2000   ; INFINITE
WAIT_PORT_TIMEOUT         equ 2000
WAIT_POST_TIMEOUT         equ 2000
WAIT_PROC_TIMEOUT         equ 2000
WORK_PROC_TIMEOUT         equ  500
WORK_EXIT_TIMEOUT         equ 1000
;------------------------------------------------
;       * * *  Status To Send/Revc  * * *
;              Send/Recv | File/Buffer | Conn/Close
;------------------------------------------------
SET_TRANS_BIT             equ  1   ;  0001
SET_SEND_BIT              equ  2   ;  0010
SET_FILE_BIT              equ  4   ;  0100
SET_PROC_BIT              equ  8   ;  1000

ROUTE_RECV_CONNECT        equ  0   ;  0000
ROUTE_RECV_BUFFER         equ  1   ;  0001
ROUTE_RECV_FILE           equ  5   ;  0101
ROUTE_RECV_END            equ  2   ;  0010

ROUTE_SEND_BUFFER         equ  3   ;  0011
ROUTE_SEND_FILE           equ  7   ;  0111

ROUTE_PROC_RECV           equ  8   ;  1000
ROUTE_PROC_SEND           equ  9   ;  1010
ROUTE_CLOSE               equ  0
;------------------------------------------------
;       * * *   END  * * *
;------------------------------------------------
