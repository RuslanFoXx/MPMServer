;-----------------------------------------------
;   AntX Web Server x32: ver.1.75
;   RESURSE: Define KeyWord Constants
;   (c) Kyiv, Ruslan FoXx
;   01 May 2024
;-----------------------------------------------
;       * * *  Define Constant KeyWords  * * *
;-----------------------------------------------
ASK_EMPTY                   equ       002h  ; Пустая строка "/"
CHR_CR                      equ        0Dh  ; Пустая строка в заголовке: "\r"
CHR_LF                      equ        0Ah  ; Пустая строка в заголовке: "\n"
END_CRLF                    equ  0A0D0A0Dh  ; Пустая строка в заголовке: "\r\n\r\n"
CHR_CRLF                    equ      0A0Dh  ; Пустая строка в заголовке: "\r\n"

EXT_LOG                     equ 000676F6Ch  ; "txt"
EXT_INI                     equ 000696E69h  ; "ini"

INS_TMP                     equ 0706D742Eh  ; ".tmp"
INS_HTM                     equ 06D74682Eh  ; ".htm"

SET_CASE_UP                 equ       0DFh  ; C and 223
SET_CASE_DOWN               equ       020h  ; c or  32

CFG_CASE_UP                 equ 0DFDFDFDFh  ; 'A-Z' AND
CFG_CASE_DOWN               equ 020202020h  ; 'a-z' OR

METHOD_CASE_UP              equ 0DFDFDFDFh  ; AAAA and 223
METHOD_CASE_DOWN            equ 020202020h  ; aaaa or  32

HEADER_HTTP                 equ 050545448h  ; HTTP-заголовок.
HEADER_HTTP_VER             equ 0312E312Fh  ; HTTP-версия.
HEADER_HTTP_VER64           equ 0312E312F50545448h  ;   HTTP/1.1-версия.

CONTENT_ID                  equ 3D444952h   ; 'RID='.
;-----------------------------------------------
;       * * *  END  * * *
;-----------------------------------------------
