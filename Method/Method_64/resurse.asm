;------------------------------------------------
;   Dynamic Link Library x32: ver.1.xx
;   MAIN: Data Resurse
;   (c) Kyiv, Ruslan FoXx
;   01 December 2023
;------------------------------------------------
;   * * *  Export Procedures * * *
;------------------------------------------------
include 'proc\string.asm'
include 'proc\url.asm'
include 'proc\header.asm'
include 'proc\http.asm'
;------------------------------------------------
;   * * *  Import Library Procedures * * *
;------------------------------------------------
section '.idata' import data readable writeable

library kernel,'KERNEL32.DLL'

import kernel,\
	GetSystemTime,	'GetSystemTime',\
	CreateFile,		'CreateFileA',\
	GetFileSizeEx,	'GetFileSizeEx',\
	ReadFile,		'ReadFile',\
	WriteFile,		'WriteFile',\
	CloseHandle,	'CloseHandle'
;------------------------------------------------
;   * * *  Export Library Procedures * * *
;------------------------------------------------
section '.edata' export data readable

export "HTTP.DLL",\
	httpGETRequest,		'httpGETRequest',\
	httpPOSTRespond,	'httpPOSTRespond',\
	httpGCIRequest,		'httpGCIRequest',\
	httpAcceptRespond,	'httpAcceptRespond',\
	httpPHPRespond,		'httpPHPRespond',\
	httpNotRespond,		'httpNotRespond'
;------------------------------------------------
;       * * *  Resources * * *
;------------------------------------------------
section '.rsrc' resource data readable

directory \
	RT_VERSION, Versions
;	RT_ICON, Icons,\
;	RT_GROUP_ICON, GroupIcons,\

;resource Icons, 1,    LANG_NEUTRAL, IconData
;resource GroupIcons,  IDR_ICON, LANG_NEUTRAL, MainIcon
resource Versions, 1,  LANG_NEUTRAL, VerInfo
;------------------------------------------------
;       * * *  Version Data Params * * *
;------------------------------------------------
versioninfo VerInfo,\
	VOS__WINDOWS32,\
	VFT_APP,\
	VFT2_UNKNOWN,\
	LANG_ENGLISH + SUBLANG_DEFAULT,\
	0,\
	'FileDescription','AntX Server Method Library x32',\
	'FileVersion','1.1',\
	'ProductName','AntXMethodLib',\
	'ProductVersion','1.1',\
	'LegalTrademarks','FoXx Co.',\
	'LegalCopyright','Ruslan FoXx',\
	'OriginalFilename','HTTP.DLL'
;	'InternalName','Grap3D'
;	'Comments','...coments'
;------------------------------------------------
;   * * *  Export Data * * *
;------------------------------------------------
section '.data' data readable writeable

;MyMethod ASK_METHOD szMethod, szAskDir, szAskProc, szAskParam
;------------------------------------------------
;   * * *  Table Ask Ext for Request  * * *
;------------------------------------------------
TabExtType:
	DB 3,'php'
	DB 4,'html',3,'htm', 3,'txt',3,'xml',3,'css',2,'js'
	DB 4,'jpeg',3,'jpg', 3,'gif',3,'ico',3,'bmp',3,'png',3,'tif',4,'tiff'
	DB 3,'pdf', 3,'xml', 3,'doc',4,'docx'
	DB 3,'mp3', 3,'wav', 2,'au', 3,'snd'
	DB 3,'zip', 4,'gzip',2,'gz', 1,'z',  3,'tar',3,'tgz',3,'rar',3,'dvi'
	DB 3,'mov', 4,'mpeg',3,'mpg',3,'mp4',3,'avi'
	DB 3,'bin', 3,'com', 3,'exe',0
;------------------------------------------------
;   * * *  Table FileType for Request  * * *
;------------------------------------------------
TabFileTypeRequest:
DD	s_text_html
	DD s_text_html,	s_text_html, s_text_plain, s_text_xml, s_text_css, s_text_javascript
	DD s_image_jpeg, s_image_jpeg, s_image_gif, s_image_icon, s_image_bmp, s_image_png, s_image_tiff, s_image_tiff
	DD s_application_pdf, s_application_msword, s_application_msword
	DD s_audio_mpeg3, s_audio_wav, s_audio_basic, s_audio_basic
	DD s_application_zip, s_application_gzip, s_application_gzip, s_application_compressed
	DD s_application_tar, s_application_tgz, s_application_rar, s_application_dvi
	DD s_video_quicktime, s_video_mpeg, s_video_mpeg, s_video_mp4, s_video_msvideo
 	DD s_application_stream , s_application_stream, s_application_stream
;------------------------------------------------
;   * * *  Label for Request  * * *
;------------------------------------------------
	HTTP_200             DB  7,'200 Ok!'
	HTTP_201             DB 11,'201 Rerform'
	HTTP_400             DB 15,'400 Bad Request'
	HTTP_403             DB 13,'403 Forbidden'
	HTTP_404             DB 13,'404 Not Found'
	HTTP_500             DB 15,'500 Not Allowed'
	HTTP_501             DB 18,'501 Internal Error'
	HTTP_503             DB 15,'503 Server Busy'
;------------------------------------------------
;   * * *  String FileType for Request  * * *
;------------------------------------------------
	s_text_html          DB  9,'text/html',0
	s_text_plain         DB 10,'text/plain',0
	s_text_xml           DB  8,'text/xml',0
	s_text_css           DB  8,'text/css',0
	s_text_javascript    DB 15,'text/javascript',0

	s_image_jpeg         DB 10,'image/jpeg',0
	s_image_gif          DB  9,'image/gif',0
	s_image_icon         DB 12,'image/x-icon',0
	s_image_bmp          DB  9,'image/bmp',0
	s_image_png          DB  9,'image/png',0
	s_image_tiff         DB 10,'image/tiff'

	s_audio_mpeg3        DB 11,'audio/mpeg3'
	s_audio_wav          DB 11,'audio/x-wav'
	s_audio_basic        DB 11,'audio/basic'

	s_video_quicktime    DB 15,'video/quicktime'
	s_video_mpeg         DB 10,'video/mpeg'
	s_video_mp4          DB  9,'video/mp4'
	s_video_msvideo      DB 15,'video/x-msvideo'

	s_application_dvi    DB 17,'application/x-dvi'
	s_application_pdf    DB 15,'application/pdf'
	s_application_msword DB 18,'application/msword'

	s_application_zip    DB 28,'application/x-zip-compressed'
	s_application_gzip   DB 18,'application/x-gzip'
	s_application_compressed DB 24,'application/x-compressed'
	s_application_tar    DB 17,'application/x-tar'
	s_application_tgz    DB 17,'application/x-tgz'
	s_application_rar    DB 28,'application/x-rar-compressed'

	s_application_stream DB 24,'application/octet-stream'
;------------------------------------------------
;   * * *  Init Server Headers  * * *
;------------------------------------------------
sWeekDateHeader               DB 'Sun,Mon,Tue,Wed,Thu,Fri,Sat,'
sMonthDateHeader              DB 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec '
sGetHttpMethod                DB '200 201 400 403 404 500 501 503 '
;------------------------------------------------
szHeaderServer                DB 13,10, 'Server: AntX/1.75 x32'
szVersionServer               DB 13,10, 'Date: '
szHeaderType                  DB ' GMT'
                              DB 13,10, 'Content-Type: '
szHeaderTextHtml              DB 'text/html'
szHeaderDisposition           DB 13,10, 'Content-Disposition: '
szAttachment                  DB 'attachment'
szHeaderLength                DB 13,10, 'Content-Length: '
szHeaderConnection            DB 13,10, 'Connection: '
szClose                       DB 'close'
szKeepAlive                   DB 'keep-alive'
szKeepAliveEnd:
;szHeaderOptions              DB 13,10, 'Allow: GET, POST, OPTIONS'
;                             DB 13,10, 'Last-Modified: Wen, 01 May 2024 10:00:00 GMT'
;szBody                       DB 13,10,13,10, '<!DOCTYPE html>'
;------------------------------------------------
;   * * *  Init Const Strings  * * *
;------------------------------------------------
szAskProc                     DB "C:\Users\FoXx\Desktop\MPMServer\CGI\main.exe",0
szAskDir                      DB "C:\Users\FoXx\Desktop\MPMServer\CGI",0
szAskParam                    DB "000 111 222 333",0

szSitePage                    DB "index.html",0
szHostPath                    DB 17,"D:\Ruslan\WebSite",0
szMethod                      DB  3,"PHP"

;szInLine                     DB 6, "inline"
;szAttachment                 DB 9, "attachment"
szFileResurse                 DB "D:\resources.tmp",0

szTransferResurse             DB "--- DATA ---", 13,10
szTransfer                    DB "<!DOCTYPE html>",10,"<html><h1>"
szTransferOk                  DB "Transferred Ok!</h1></html>"
szTransferError               DB "Receiver Error!</h1></html>"
szTransferEnd:
;------------------------------------------------
;   * * *  ConfigParamWords
;------------------------------------------------
sStrByteScale           DD MAX_INT_SCALE dup(?)
MyMethod                   ASK_METHOD ?
ServerTime                 SYSTEMTIME ?
lpSocketIoData             LPVOID ?
hFile                      HANDLE ?

Connection                 QWORD ?
ReadBytes                  QWORD ?
CountBytes                 QWORD ?
Param                      QWORD ?
Len                        QWORD ?
pBuffer                    PCHAR ?
pNetHost                   PCHAR ?

szFileName              DB MAX_PATH_SIZE dup(?)
szFileExt               DB MAX_EXT_SIZE  dup(?)
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
