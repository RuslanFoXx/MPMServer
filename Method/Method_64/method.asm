;------------------------------------------------
;   Dynamic Link Library x32: ver.1.xx
;   MAIN: DLL
;   (c) Kyiv, Ruslan FoXx
;   01 December 2023
;------------------------------------------------
;   * * *  Include System Library
;          you can simply switch between win32ax, win32wx, win64ax and win64wx here
;------------------------------------------------
include 'method.inc'

format PE64 GUI 4.0 DLL
entry DllEntryPoint
;------------------------------------------------
;
;   * * *  MainProc  * * *
;
;------------------------------------------------
;section '.code' code readable executable

proc DllEntryPoint ;  hInstance, fdwReason, lpvReserved

;   mov RDX, RDX   ;  fdwReason
    xor RAX, RAX

    cmp EAX, EDX   ;   DLL_PROCESS_DETACH = 0
        je jmpProcDetach@DllEntryPoint

    inc EDX
    cmp EAX, EDX   ;   DLL_PROCESS_ATTACH = 1
        je jmpProcAttach@DllEntryPoint

    inc EDX
    cmp EAX, EDX   ;   DLL_THREAD_ATTACH  = 2
        je jmpThreadAttach@DllEntryPoint

    inc EDX
    cmp EAX, EDX   ;   DLL_THREAD_DETACH  = 3
;       je jmpThreadDetach@DllEntryPoint
        jne jmpEnd@DllEntryPoint

jmpProcAttach@DllEntryPoint:
;   inc [SystemInformation.ProcAttachCount]
    jmp jmpEnd@DllEntryPoint

jmpThreadAttach@DllEntryPoint:
;   inc [SystemInformation.ThreadAttachCount]
;   jmp jmpEnd@DllEntryPoint

jmpThreadDetach@DllEntryPoint:
;   inc [ThreadDetach]
;   jmp jmpEnd@DllEntryPoint

jmpProcDetach@DllEntryPoint:
;   inc [ProcDetach]
;   jmp jmpEnd@DllEntryPoint
;------------------------------------------------
;   * * *  Set Digital Scale
;------------------------------------------------
    mov EDI, sStrByteScale
    mov ECX, MAX_INT_SCALE
    mov  DX, '00'
    mov EBX, EDX

jmpSet@DllEntryPoint:
    cmp DH, '9'
        jbe jmp10@DllEntryPoint
        mov DH, '0'
        inc DL

jmp10@DllEntryPoint:
        cmp DL, '9'
            jbe jmp100@DllEntryPoint
            mov DL, '0'
            inc BH

jmp100@DllEntryPoint:
    mov EAX, EBX
    stosw

    mov EAX, EDX
    stosw

    inc DH
    loop jmpSet@DllEntryPoint
;------------------------------------------------
;   * * *  DLL Exit  * * *
;------------------------------------------------
jmpEnd@DllEntryPoint:
    xor EAX, EAX
    inc EAX
    ret
endp

include 'resurse.asm'
;------------------------------------------------
;   * * *  ReLockate Memory * * *
;------------------------------------------------
section '.reloc' fixups data readable discardable
if $ = $$
   fixups dd 0, 8   ;   if there are no fixups, generate dummy entry
end if
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
