;------------------------------------------------
;	Multi-Purpose MiddleWare Server (MPM)
;	RESURSE: Define KeyWord Constants
;	ver.1.75 (x32)
;	(c) Kyiv, Ruslan FoXx
;	01 July 2024
;------------------------------------------------
;       * * *  Config Mode Params
;------------------------------------------------
CFG_PARAM_ENUM				equ  18			; SERVER_CONFIG + ASK_METHOD + NET_HOST

CFG_INDEX_METHOD			equ  44			; SERVER_CONFIG_PARAM ( 9 )
CFG_INDEX_HOST				equ  64			; CFG_INDEX_METHOD + ASK_METHOD_PARAM ( 9 + 5 )

CFG_OFFSET_METHOD			equ  44			; CFG_INDEX_METHOD ( 88 )
CFG_OFFSET_HOST				equ  80			; CFG_INDEX_HOST + NET_HOST_SIZE ( 128 + 16 )
;------------------------------------------------
;       * * *  Define Constant KeyWords  * * *
;------------------------------------------------
CHR_CR						equ        0Dh	; Пустая строка в заголовке: "\r"
CHR_LF						equ        0Ah	; Пустая строка в заголовке: "\n"
CHR_CRLF					equ      0A0Dh	; Пустая строка в заголовке: "\r\n"

EXT_LOG						equ 000676F6Ch	; "txt"
EXT_INI						equ 000696E69h  ; "ini"

KEY_CASE_UP					equ 0DFDFDFDFh  ; 'A-Z' AND 223
KEY_CASE_DOWN				equ 020202020h  ; 'a-z' OR  32
;------------------------------------------------
;       * * *  END  * * *
;------------------------------------------------