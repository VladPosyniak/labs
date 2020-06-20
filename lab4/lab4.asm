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

DlgProc         proto hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

; �������������� ��������
IDD_MAIN = 1000
IDC_STC1 = 1001
IDC_EDT1 = 1002
IDC_BTN1 = 1003
IDC_EDT2 = 1004
IDC_EDT3 = 1005
IDC_EDT4 = 1006

CODE_BYTE = 5Ah                                 ; ��� ����������

;-- ������� ------------------------------------------------------------------------------------------------------------

; ������� ������������� ����� CODE_BYTE ������ �� �������� String, ����������� <� ������� ������>
StrCipher       macro   String
        forc    x, <String>
                DB      '&x' xor CODE_BYTE
        endm
endm

; ������� ������ �� ������ TextAddr (������� ��� ��������� addr ��� offset) � ������� ������� Id
SetText         macro   Id, TextAddr
                invoke  SetDlgItemText, hwnd, Id, addr TextAddr
endm

; ��������� ������ � ������ String (������� ��� ��������� addr ��� offset)
; ���������� ZF=1 � ������ ������
CheckPassword   macro String
                local A
                push esi
                push edi
                mov ecx,PwdLen                  ; ����� ������
                mov esi,offset String
                mov edi,offset Pwd

        A:      lodsb                           ; ������ ������ ������
                xor al,CODE_BYTE                ; ����������� ���
                scasb                           ; ���������� ��� � ��������
                loopz A                         ; ��������� ECX ���, ���� ���������

                pop edi
                pop esi
endm

;-- ������ -------------------------------------------------------------------------------------------------------------

.DATA

Pwd     LABEL BYTE
        StrCipher <hello>                       ; ������������� ������
        db CODE_BYTE
PwdLen  = $-Pwd                                 ; ����� ������
Txt     db '�������� ������!',0
Ttl     db 'Error',0
Data1   db '�������: ������� ��������� �������',0
Data2   db '���� ��������: 06.03.2001',0
Data3   db '����� ���. ������: 8208',0

;-- �������������������� ������ ----------------------------------------------------------------------------------------

.DATA?

Buf     db 20 dup (?)                           ; ����� ��� ������

.CODE

;-- ������� ��������� --------------------------------------------------------------------------------------------------
Start:
        ; �������� �����
        invoke GetModuleHandle, NULL            ; �������� ����� �������� ������
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; ������ ���������� ���� (������� ������� � ��������)
        invoke ExitProcess, NULL                ; ������� �� ���������

;-- ���������� ��������� ������� ---------------------------------------------------------------------------------------
DlgProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        .if uMsg == WM_INITDIALOG
          invoke GetDlgItem, hwnd, IDC_EDT2
          invoke ShowWindow, eax, SW_HIDE       ; ������ ���� � ������� �������� (���� ������)
          invoke GetDlgItem, hwnd, IDC_EDT3
          invoke ShowWindow, eax, SW_HIDE
          invoke GetDlgItem, hwnd, IDC_EDT4
          invoke ShowWindow, eax, SW_HIDE
          mov eax,TRUE

        .elseif (uMsg == WM_COMMAND) && (wParam == BN_CLICKED shl 10h + IDC_BTN1) ; ������� ������ "OK"
          invoke GetDlgItemText, hwnd, IDC_EDT1, addr Buf, sizeof Buf ; ���������� ������ � ����
          CheckPassword Buf                     ; ��������� ������
          jnz error
          invoke GetDlgItem, hwnd, IDC_STC1
          invoke ShowWindow, eax, SW_HIDE       ; ������ ���� ����� ������
          invoke GetDlgItem, hwnd, IDC_EDT1
          invoke ShowWindow, eax, SW_HIDE
          invoke GetDlgItem, hwnd, IDC_BTN1
          invoke ShowWindow, eax, SW_HIDE
          SetText IDC_EDT2, Data1               ; ���������� ������ �������� � ����
          SetText IDC_EDT3, Data2               ; ���������� ������ �������� � ����
          SetText IDC_EDT4, Data3               ; ���������� ������ �������� � ����
          invoke GetDlgItem, hwnd, IDC_EDT2
          invoke ShowWindow, eax, SW_SHOW       ; ���������� ���� � ������� ��������
          invoke GetDlgItem, hwnd, IDC_EDT3
          invoke ShowWindow, eax, SW_SHOW
          invoke GetDlgItem, hwnd, IDC_EDT4
          invoke ShowWindow, eax, SW_SHOW
          jmp ok
error:    invoke MessageBox, 0, addr Txt, addr Ttl, MB_OK or MB_ICONWARNING
ok:       mov eax,TRUE

        .elseif uMsg == WM_CLOSE                ; �������� ����
          invoke EndDialog, hwnd, NULL          ; ������� ������
          mov eax,TRUE

        .else
          xor eax,eax
        .endif
        ret
DlgProc endp

end Start
