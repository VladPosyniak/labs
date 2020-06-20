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

; �������������� ��������
IDD_MAIN = 1000
IDC_EDT1 = 1001

; ������

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

; ������
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
        db 0                            ; ����� ������

fmtInt1 db ' = %lli = %02hhX (hex) = ',0
fmtInt2 db ' = %lli = %04hX (hex) = ',0
fmtInt4 db ' = %lli = %08X (hex) = ',0
fmtInt8 db ' = %lli = %016llX (hex) = ',0

fmtFP4  db ' = %.3f = %08X (hex) = ',0
fmtFP8  db ' = %.3f = %016llX (hex) = ',0
fmtFP10 db ' = %.3f = %016llX%04hX (hex) = ',0

; �������������������� ������

.DATA?

TextBuf db 1000 dup (?)                 ; ����� ��� ������
Temp    dq ?                            ; ����� ��� ������������� �����

.CODE

; ������� ���������
Start:
        fninit                          ; ������������� ��������������� ������������
        invoke GetModuleHandle, NULL    ; �������� ����� �������� ������
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; ������ ���������� ���� (������� ������� � ��������)
        invoke ExitProcess, NULL        ; ������� �� ���������

; ���������� ��������� �������
DlgProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        cmp uMsg,WM_INITDIALOG          ; ������������� �������?
        jne b1
        invoke StrWrite                 ; ���������� ������
        invoke SetDlgItemText, hwnd, IDC_EDT1, addr TextBuf ; ���������� ������ � ����
        mov eax,TRUE
        jmp dexit
b1:
        cmp uMsg,WM_CLOSE               ; �������� ����?
        jne b2
        invoke EndDialog, hwnd, NULL    ; ������� ������
        mov eax,TRUE
        jmp dexit
b2:
        xor eax,eax
dexit:
        ret
DlgProc endp

; ���������� ������
StrWrite proc uses ebx esi edi
        mov ebx,offset A                ; �������� ������
        mov esi,offset Strings          ; ������ ����� ���������� ������
        mov edi,offset TextBuf          ; ���� ����� ���������� ������
copyloop:
        invoke crt_strlen, esi          ; �������� ����� ������
        lea ecx,[eax+1]                 ; ����� ������ ������ � ����-������������
        rep movsb                       ; �������� ��������� ������ �� Stirngs
        dec edi                         ; �� ������� �����

        lodsb                           ; ������ ��� ������
        push esi
        movzx ecx,al                    ; ecx = ���-�� ����
        .if al < 10
          push ecx
          .if al == 1
            movsx eax,byte ptr [ebx]    ; ������ Byte
            movzx ecx,al
            mov esi,offset fmtInt1
          .elseif al == 2
            movsx eax,word ptr [ebx]    ; ������ Word
            movzx ecx,ax
            mov esi,offset fmtInt2
          .elseif al == 4
            mov eax,[ebx]               ; ������ Shortint
            mov ecx,eax
            mov esi,offset fmtInt4
          .else ; al == 8
            mov eax,[ebx]               ; ������ Longint
            mov ecx,eax
            mov esi,offset fmtInt8
          .endif
          cdq                           ; ������� ����� �����

          push eax
          push edx
          invoke crt_sprintf, edi, esi, eax, edx, ecx, edx ; ������� ����� � ������
          add edi,eax                   ; �������� ������� �� ���-�� ���������� ��������
          pop edx
          pop eax

        .else ; al >= 10
          sub cl,10
          push ecx
          .if al == 14
            mov eax,[ebx]
            fld dword ptr [ebx]         ; ��������� Single
            fstp Temp                   ; �������� ����� � Temp ��� Double
            mov esi,offset fmtFP4
          .elseif al == 18
            mov eax,[ebx]
            mov edx,[ebx+4]
            fld qword ptr [ebx]         ; ��������� Double
            fstp Temp                   ; �������� ����� � Temp ��� Double
            mov esi,offset fmtFP8
          .else ; al == 20
            mov eax,[ebx+2]
            mov edx,[ebx+6]
            movzx ecx,word ptr [ebx]    ; ������� �����
            fld tbyte ptr [ebx]         ; ��������� Extended
            fstp Temp                   ; �������� ����� � Temp ��� Double
            mov esi,offset fmtFP10
          .endif

          push eax
          push edx
          invoke crt_sprintf, edi, esi, dword ptr [Temp], dword ptr [Temp+4], eax, edx, ecx ; ������� ����� � ������
          add edi,eax           ; �������� ������� �� ���-�� ���������� ��������
          pop edx
          pop eax
        .endif
        pop ecx                         ; ����� ����� � ������
        add ebx,ecx                     ; ��������� � ���������� �����
        shl ecx,3                       ; ���-�� �����
        cmp ecx,80
        jne notext                      ; �������, ���� �� Extended
        mov cl,64                       ; ����� ���� ����� �������� 64 ����
notext:
        invoke OutBin                   ; ����������� � �������� �����
        pop esi

        cmp byte ptr [esi-1],20
        jne notext2                     ; �������, ���� �� Extended
        mov ax,[ebx-10]                 ; ���� ������� 2 �����
        mov cl,16
        invoke OutBin                   ; ����������� � �������� �����
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
        mov al,')'                      ; ������ " (bin)"
        stosb
        mov al,13
        stosb
        mov al,10
        stosb                           ; ������� ������

        cmp byte ptr [esi],0
        jne copyloop                    ; ���������, ���� ���� ��� ������

        movsb                           ; ����� ������
        ret
StrWrite endp

; �������� �������� ����� EDX:EAX ������ ECX �����
OutBin proc
        push ecx
        neg ecx
        add ecx,64                      ; ecx = 64 - (���-�� �����)
        cmp ecx,32
        jb less32                       ; �������, ���� ecx < 32
        mov edx,eax                     ; ��������� eax � edx, ���� ecx >= 32 (�.�. ����� shld � shl �� ���������)
        xor eax,eax
less32: shld edx,eax,cl
        shl eax,cl
        pop ecx
nextbin:
        shl eax,1
        rcl edx,1                       ; �������� �� 1 ���
        push eax
        mov al,'0'
        adc al,0                        ; ����������� � �������� �����
        stosb
        pop eax
        loop nextbin                    ; ��������� ecx ���
        ret
OutBin endp

end Start
