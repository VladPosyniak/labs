.686p
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib

DlgProc  proto hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
StrWrite proto
OutBin   proto

; »дентификаторы ресурсов
IDD_MAIN = 1000
IDC_EDT1 = 1001

; ƒанные

.DATA

A       db 6
        db -6
        dw 6
        dw -6
        dd 6
        dd -6
        dq 6
        dq -6

B       dw 603
        dw -603
        dd 603
        dd -603
        dq 603
        dq -603

C_      dd 6032001
        dd -6032001
        dq 6032001
        dq -6032001

D       dd 0.001  ; 6/8208
        dd -0.001 ; 6/8208
        dq 0.001  ; 6/8208
        dq -0.001 ; 6/8208
        dt 0.001  ; 6/8208
        dt -0.001 ; 6/8208

E       dd 0.073  ; 603/8208
        dd -0.073 ; 603/8208
        dq 0.073  ; 603/8208
        dq -0.073 ; 603/8208
        dt 0.073  ; 603/8208
        dt -0.073 ; 603/8208

F       dd 734.893  ; 6032001/8208
        dd -734.893 ; 6032001/8208
        dq 734.893  ; 6032001/8208
        dq -734.893 ; 6032001/8208
        dt 734.893  ; 6032001/8208
        dt -734.893 ; 6032001/8208

; —троки
Strings db ' A [Byte]',0, 1
        db '-A [Byte]',0, 1
        db ' A [Word]',0, 2
        db '-A [Word]',0, 2
        db ' A [Shortint]',0, 4
        db '-A [Shortint]',0, 4
        db ' A [Longint]',0, 8
        db '-A [Longint]',0, 8
                        
        db 13,10,' B [Word]',0, 2
        db '-B [Word]',0, 2
        db ' B [Shortint]',0, 4
        db '-B [Shortint]',0, 4
        db ' B [Longint]',0, 8
        db '-B [Longint]',0, 8
                        
        db 13,10,' C [Shortint]',0, 4
        db '-C [Shortint]',0, 4
        db ' C [Longint]',0, 8
        db '-C [Longint]',0, 8
                        
        db 13,10,' D [Single]',0, 14
        db '-D [Single]',0, 14
        db ' D [Double]',0, 18
        db '-D [Double]',0, 18
        db ' D [Extended]',0, 20
        db '-D [Extended]',0, 20
                        
        db 13,10,' E [Single]',0, 14
        db '-E [Single]',0, 14
        db ' E [Double]',0, 18
        db '-E [Double]',0, 18
        db ' E [Extended]',0, 20
        db '-E [Extended]',0, 20
                        
        db 13,10,' F [Single]',0, 14
        db '-F [Single]',0, 14
        db ' F [Double]',0, 18
        db '-F [Double]',0, 18
        db ' F [Extended]',0, 20
        db '-F [Extended]',0, 20
        db 0                            ; конец данных

fmtInt1 db ' = %lli = %02hhX (hex) = ',0
fmtInt2 db ' = %lli = %04hX (hex) = ',0
fmtInt4 db ' = %lli = %08X (hex) = ',0
fmtInt8 db ' = %lli = %016llX (hex) = ',0

fmtFP4  db ' = %.3f = %08X (hex) = ',0
fmtFP8  db ' = %.3f = %016llX (hex) = ',0
fmtFP10 db ' = %.3f = %016llX%04hX (hex) = ',0

; Ќеинициализированные данные

.DATA?

TextBuf db 1000 dup (?)                 ; буфер дл€ строки
Temp    dq ?                            ; буфер дл€ вещественного числа

.CODE

; √лавна€ процедура
Start:
        fninit                          ; инициализаци€ математического сопроцессора
        invoke GetModuleHandle, NULL    ; получаем хендл текущего модул€
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; создаЄм диалоговое окно (которое описано в ресурсах)
        invoke ExitProcess, NULL        ; выходим из программы

; ќбработчик сообщений диалога
DlgProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        cmp uMsg,WM_INITDIALOG          ; инициализаци€ диалога?
        jne b1
        invoke StrWrite                 ; подготовка строки
        invoke SetDlgItemText, hwnd, IDC_EDT1, addr TextBuf ; записываем строку в окно
        mov eax,TRUE
        jmp dexit
b1:
        cmp uMsg,WM_CLOSE               ; закрытие окна?
        jne b2
        invoke EndDialog, hwnd, NULL    ; закрыть диалог
        mov eax,TRUE
        jmp dexit
b2:
        xor eax,eax
dexit:
        ret
DlgProc endp

; ѕодготовка строки
StrWrite proc uses ebx esi edi
        mov ebx,offset A                ; исходные данные
        mov esi,offset Strings          ; откуда будем копировать строки
        mov edi,offset TextBuf          ; куда будем копировать строки
copyloop:
        invoke crt_strlen, esi          ; получаем длину строки
        lea ecx,[eax+1]                 ; длина строки вместе с нуль-терминатором
        rep movsb                       ; копируем следующую строку из Stirngs
        dec edi                         ; на позицию назад

        lodsb                           ; читаем код данных
        push esi
        movzx ecx,al                    ; ecx = кол-во цифр
        .if al < 10
          push ecx
          .if al == 1
            movsx eax,byte ptr [ebx]    ; читаем Byte
            movzx ecx,al
            mov esi,offset fmtInt1
          .elseif al == 2
            movsx eax,word ptr [ebx]    ; читаем Word
            movzx ecx,ax
            mov esi,offset fmtInt2
          .elseif al == 4
            mov eax,[ebx]               ; читаем Shortint
            mov ecx,eax
            mov esi,offset fmtInt4
          .else ; al == 8
            mov eax,[ebx]               ; читаем Longint
            mov ecx,eax
            mov esi,offset fmtInt8
          .endif
          cdq                           ; старша€ часть числа

          push eax
          push edx
          invoke crt_sprintf, edi, esi, eax, edx, ecx, edx ; выводим число в строку
          add edi,eax                   ; сдвигаем позицию на кол-во записанных символов
          pop edx
          pop eax

        .else ; al >= 10
          sub cl,10
          push ecx
          .if al == 14
            mov eax,[ebx]
            fld dword ptr [ebx]         ; загружаем Single
            fstp Temp                   ; копируем число в Temp как Double
            mov esi,offset fmtFP4
          .elseif al == 18
            mov eax,[ebx]
            mov edx,[ebx+4]
            fld qword ptr [ebx]         ; загружаем Double
            fstp Temp                   ; копируем число в Temp как Double
            mov esi,offset fmtFP8
          .else ; al == 20
            mov eax,[ebx+2]
            mov edx,[ebx+6]
            movzx ecx,word ptr [ebx]    ; младша€ часть
            fld tbyte ptr [ebx]         ; загружаем Extended
            fstp Temp                   ; копируем число в Temp как Double
            mov esi,offset fmtFP10
          .endif

          push eax
          push edx
          invoke crt_sprintf, edi, esi, dword ptr [Temp], dword ptr [Temp+4], eax, edx, ecx ; выводим число в строку
          add edi,eax           ; сдвигаем позицию на кол-во записанных символов
          pop edx
          pop eax
        .endif
        pop ecx                         ; длина числа в байтах
        add ebx,ecx                     ; переходим к следующему числу
        shl ecx,3                       ; кол-во битов
        cmp ecx,80
        jne notext                      ; прыгаем, если не Extended
        mov cl,64                       ; иначе пока будем выводить 64 бита
notext:
        invoke OutBin                   ; преобразуем в двоичное число
        pop esi

        cmp byte ptr [esi-1],20
        jne notext2                     ; прыгаем, если не Extended
        mov ax,[ebx-10]                 ; берЄм младшие 2 байта
        mov cl,16
        invoke OutBin                   ; преобразуем в двоичное число
notext2:
        mov al,' '
        stosb
        mov al,'('
        stosb
        mov al,'b'
        stosb
        mov al,'i'
        stosb
        mov al,'n'
        stosb
        mov al,')'                      ; строка " (bin)"
        stosb
        mov al,13
        stosb
        mov al,10
        stosb                           ; перевод строки

        cmp byte ptr [esi],0
        jne copyloop                    ; повтор€ем, если есть ещЄ данные

        movsb                           ; конец строки
        ret
StrWrite endp

; «аписать двоичное число EDX:EAX длиной ECX битов
OutBin proc
        push ecx
        neg ecx
        add ecx,64                      ; ecx = 64 - (кол-во битов)
        cmp ecx,32
        jb less32                       ; прыгаем, если ecx < 32
        mov edx,eax                     ; переносим eax в edx, если ecx >= 32 (т.к. иначе shld и shl не сработают)
        xor eax,eax
less32: shld edx,eax,cl
        shl eax,cl
        pop ecx
nextbin:
        shl eax,1
        rcl edx,1                       ; сдвигаем на 1 бит
        push eax
        mov al,'0'
        adc al,0                        ; преобразуем в двоичное число
        stosb
        pop eax
        loop nextbin                    ; повтор€ем ecx раз
        ret
OutBin endp

end Start
