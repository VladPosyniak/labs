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

; Идентификаторы ресурсов
IDD_MAIN = 1000
IDC_STC1 = 1001
IDC_EDT1 = 1002
IDC_BTN1 = 1003
IDC_EDT2 = 1004
IDC_EDT3 = 1005
IDC_EDT4 = 1006

CODE_BYTE = 5Ah                                 ; код шифрования

;-- Макросы ------------------------------------------------------------------------------------------------------------

; Создать зашифрованный кодом CODE_BYTE пароль из символов String, заключенных <в угловые скобки>
StrCipher       macro   String
        forc    x, <String>
                DB      '&x' xor CODE_BYTE
        endm
endm

; Вывести строку по адресу TextAddr (задаётся без директивы addr или offset) в элемент диалога Id
SetText         macro   Id, TextAddr
                invoke  SetDlgItemText, hwnd, Id, addr TextAddr
endm

; Проверить пароль в строке String (задаётся без директивы addr или offset)
; Возвращает ZF=1 в случае успеха
CheckPassword   macro String
                local A
                push esi
                push edi
                mov ecx,PwdLen                  ; длина пароля
                mov esi,offset String
                mov edi,offset Pwd

        A:      lodsb                           ; читаем символ пароля
                xor al,CODE_BYTE                ; раскодируем его
                scasb                           ; сравниваем его с символом
                loopz A                         ; повторяем ECX раз, пока совпадают

                pop edi
                pop esi
endm

;-- Данные -------------------------------------------------------------------------------------------------------------

.DATA

Pwd     LABEL BYTE
        StrCipher <hello>                       ; зашифрованная строка
        db CODE_BYTE
PwdLen  = $-Pwd                                 ; длина пароля
Txt     db 'Неверный пароль!',0
Ttl     db 'Error',0
Data1   db 'Студент: Посыняк Владислав Юрьевич',0
Data2   db 'День рождения: 06.03.2001',0
Data3   db 'Номер зач. книжки: 8208',0

;-- Неинициализированные данные ----------------------------------------------------------------------------------------

.DATA?

Buf     db 20 dup (?)                           ; буфер для строки

.CODE

;-- Главная процедура --------------------------------------------------------------------------------------------------
Start:
        ; Создание формы
        invoke GetModuleHandle, NULL            ; получаем хендл текущего модуля
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; создаём диалоговое окно (которое описано в ресурсах)
        invoke ExitProcess, NULL                ; выходим из программы

;-- Обработчик сообщений диалога ---------------------------------------------------------------------------------------
DlgProc proc hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        .if uMsg == WM_INITDIALOG
          invoke GetDlgItem, hwnd, IDC_EDT2
          invoke ShowWindow, eax, SW_HIDE       ; прячем окна с данными студента (пока пустые)
          invoke GetDlgItem, hwnd, IDC_EDT3
          invoke ShowWindow, eax, SW_HIDE
          invoke GetDlgItem, hwnd, IDC_EDT4
          invoke ShowWindow, eax, SW_HIDE
          mov eax,TRUE

        .elseif (uMsg == WM_COMMAND) && (wParam == BN_CLICKED shl 10h + IDC_BTN1) ; нажатие кнопки "OK"
          invoke GetDlgItemText, hwnd, IDC_EDT1, addr Buf, sizeof Buf ; записываем строку в окно
          CheckPassword Buf                     ; проверить пароль
          jnz error
          invoke GetDlgItem, hwnd, IDC_STC1
          invoke ShowWindow, eax, SW_HIDE       ; прячем окна ввода пароля
          invoke GetDlgItem, hwnd, IDC_EDT1
          invoke ShowWindow, eax, SW_HIDE
          invoke GetDlgItem, hwnd, IDC_BTN1
          invoke ShowWindow, eax, SW_HIDE
          SetText IDC_EDT2, Data1               ; записываем данные студента в окно
          SetText IDC_EDT3, Data2               ; записываем данные студента в окно
          SetText IDC_EDT4, Data3               ; записываем данные студента в окно
          invoke GetDlgItem, hwnd, IDC_EDT2
          invoke ShowWindow, eax, SW_SHOW       ; показываем окна с данными студента
          invoke GetDlgItem, hwnd, IDC_EDT3
          invoke ShowWindow, eax, SW_SHOW
          invoke GetDlgItem, hwnd, IDC_EDT4
          invoke ShowWindow, eax, SW_SHOW
          jmp ok
error:    invoke MessageBox, 0, addr Txt, addr Ttl, MB_OK or MB_ICONWARNING
ok:       mov eax,TRUE

        .elseif uMsg == WM_CLOSE                ; закрытие окна
          invoke EndDialog, hwnd, NULL          ; закрыть диалог
          mov eax,TRUE

        .else
          xor eax,eax
        .endif
        ret
DlgProc endp

end Start
