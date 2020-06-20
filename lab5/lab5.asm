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
Calculate       proto

; �������������� ��������
IDD_MAIN = 1000
IDC_EDT1 = 1001
IDC_EDT2 = 1002
IDC_EDT3 = 1003
IDC_EDT4 = 1004
IDC_EDT5 = 1005
IDC_EDT6 = 1006
IDC_EDT7 = 1007
IDC_EDT8 = 1008
IDC_EDT9 = 1009
IDC_EDT10 = 1010
IDC_EDT11 = 1011
IDC_EDT12 = 1012
IDC_EDT13 = 1013
IDC_EDT14 = 1014
IDC_EDT15 = 1015
IDC_EDT16 = 1016
IDC_EDT17 = 1017
IDC_EDT18 = 1018
IDC_EDT19 = 1019
IDC_EDT20 = 1020
IDC_STC1 = 1021
IDC_STC2 = 1022
IDC_STC3 = 1023
IDC_STC4 = 1024
IDC_BTN1 = 1025
IDC_STC5 = 1026
IDC_STC6 = 1027
IDC_STC7 = 1028
IDC_STC8 = 1029

;-- ������ -------------------------------------------------------------------------------------------------------------

.DATA

ErrorText       db '������: �������� ����� ���� ����� = 0 ��� 1.',0
ErrorTitle      db 'Error',0
ErrorResult     db 'ZeroDiv',0

;-- �������������������� ������ ----------------------------------------------------------------------------------------

.DATA?

; �������� ���������� �� ����������� ���� � ���������� ��������
A       dd 5 dup (?)
B       dd 5 dup (?)
C_      dd 5 dup (?)
Result  dd 5 dup (?)                            ; ����������
Ok      dd 5 dup (?)                            ; 1 � ������� �����, ���� ��������� ��������� (�� ���� �� ������� �� ����)

Success db ?                                    ; ���������� ���������� ������ ������ ����� �� ����������� ����

.CODE

;-- ������� ��������� --------------------------------------------------------------------------------------------------
Start:
        invoke GetModuleHandle, NULL            ; �������� ����� �������� ������
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; ������ ���������� ���� (������� ������� � ��������)
        invoke ExitProcess, NULL                ; ������� �� ���������

;-- ���������� ��������� ������� ---------------------------------------------------------------------------------------
DlgProc proc uses ebx esi edi, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

        .if (uMsg == WM_COMMAND) && (wParam == BN_CLICKED shl 10h + IDC_BTN1) ; ������� ������ "OK"
          ; ������ ������
          mov ebx,IDC_EDT1                      ; id ������� ���� ������
          mov edi,offset A                      ; ����� ����������
get_next:
          invoke GetDlgItemInt, hwnd, ebx, addr Success, TRUE ; ������ �������� �������� �������� �� ���� ����� ebx
          cmp Success,TRUE
          jne error_val                         ; �������� ��������
          cmp eax,1
          jbe error_val                         ; �������� �������� (0 ��� 1)
          stosd                                 ; ���������� ����������� ��������
          inc ebx                               ; � ���������� ����
          cmp ebx,IDC_EDT15
          jbe get_next                          ; ��������� � ����������

          ; ����������
          invoke Calculate

          ; ����� ����������
          mov esi,offset Result                 ; ����� ����������
set_next:
          cmp byte ptr [esi + 4*5],1            ; Ok
          lodsd
          jnz wrong                             ; �������, ���� ��������� ��������
          invoke SetDlgItemInt, hwnd, ebx, eax, TRUE ; ������� ���������
          jmp r_ok
wrong:    invoke SetDlgItemText, hwnd, ebx, addr ErrorResult ; ������� ������
r_ok:     inc ebx                               ; � ���������� ����
          cmp ebx,IDC_EDT20
          jbe set_next                          ; ��������� � ����������
          jmp finish

          ; ��������� �� ������ � ����������
error_val:
          invoke MessageBox, 0, addr ErrorText, addr ErrorTitle, MB_OK or MB_ICONWARNING ; ��������� � ������
          invoke GetDlgItem, hwnd, ebx
          invoke SetFocus, eax                  ; ���������� ����� �� ���� � �������
finish:
          mov eax,TRUE

        .elseif uMsg == WM_CLOSE                ; �������� ����
          invoke EndDialog, hwnd, NULL          ; ������� ������
          mov eax,TRUE

        .else
          xor eax,eax
        .endif
        ret
DlgProc endp

; ������
Calculate proc uses ebx esi edi
        mov esi,offset A
        mov edi,offset Result
calc_next:
        ; (a*b/4 - 1)/(41-b*a + c)
        mov byte ptr [edi + 4*5],0              ; Ok = FALSE

        mov ecx,[esi]                           ; a
        imul ecx,[esi + 4*5]                    ; a*b
        mov eax,ecx
        neg ecx
        add ecx,41                              ; 41-a*b
        add ecx,[esi + 4*5*2]                   ; 41-a*b+c
        jz calc_end                             ; �������, ���� ��������� ���� (������� �� 0), ������

        cdq                                     ; eax -> edx:eax (a*b)
        mov ebx,4
        idiv ebx                                ; a*b/4
        dec eax

        cdq
        idiv ecx                                ; (a*b/4 - 1)/(41-b*a + c)

        inc byte ptr [edi + 4*5]                ; Ok = TRUE

        test eax,1
        jnz odd
        sar eax,1                               ; ������: ����� ��������� �� 2
        jmp calc_end
odd:    imul eax,5                              ; ��������: �������� �� 5
calc_end:
        stosd                                   ; ���������� ���������
        add esi,4                               ; � ���������� �����
        cmp esi,offset B
        jb calc_next                            ; ���������

        ret
Calculate endp

end Start
