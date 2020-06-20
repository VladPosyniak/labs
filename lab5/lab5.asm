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

; Идентификаторы ресурсов
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

;-- Данные -------------------------------------------------------------------------------------------------------------

.DATA

ErrorText       db 'Ошибка: неверное число либо число = 0 или 1.',0
ErrorTitle      db 'Error',0
ErrorResult     db 'ZeroDiv',0

;-- Неинициализированные данные ----------------------------------------------------------------------------------------

.DATA?

; Значения переменных из диалогового окна и результаты расчётов
A       dd 5 dup (?)
B       dd 5 dup (?)
C_      dd 5 dup (?)
Result  dd 5 dup (?)                            ; результаты
Ok      dd 5 dup (?)                            ; 1 в младшем байте, если результат корректен (не было ли деления на ноль)

Success db ?                                    ; успешность результата чтения целого числа из диалогового окна

.CODE

;-- Главная процедура --------------------------------------------------------------------------------------------------
Start:
        invoke GetModuleHandle, NULL            ; получаем хендл текущего модуля
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; создаём диалоговое окно (которое описано в ресурсах)
        invoke ExitProcess, NULL                ; выходим из программы

;-- Обработчик сообщений диалога ---------------------------------------------------------------------------------------
DlgProc proc uses ebx esi edi, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

        .if (uMsg == WM_COMMAND) && (wParam == BN_CLICKED shl 10h + IDC_BTN1) ; нажатие кнопки "OK"
          ; Чтение данных
          mov ebx,IDC_EDT1                      ; id первого окна данных
          mov edi,offset A                      ; адрес переменной
get_next:
          invoke GetDlgItemInt, hwnd, ebx, addr Success, TRUE ; читаем числовое знаковое значение из окна ввода ebx
          cmp Success,TRUE
          jne error_val                         ; неверное значение
          cmp eax,1
          jbe error_val                         ; неверное значение (0 или 1)
          stosd                                 ; записываем прочитанное значение
          inc ebx                               ; к следующему окну
          cmp ebx,IDC_EDT15
          jbe get_next                          ; переходим к следующему

          ; Вычисление
          invoke Calculate

          ; Вывод результата
          mov esi,offset Result                 ; адрес результата
set_next:
          cmp byte ptr [esi + 4*5],1            ; Ok
          lodsd
          jnz wrong                             ; прыгаем, если результат НЕверный
          invoke SetDlgItemInt, hwnd, ebx, eax, TRUE ; выводим результат
          jmp r_ok
wrong:    invoke SetDlgItemText, hwnd, ebx, addr ErrorResult ; выводим ошибку
r_ok:     inc ebx                               ; к следующему окну
          cmp ebx,IDC_EDT20
          jbe set_next                          ; переходим к следующему
          jmp finish

          ; Сообщение об ошибке и завершение
error_val:
          invoke MessageBox, 0, addr ErrorText, addr ErrorTitle, MB_OK or MB_ICONWARNING ; сообщение о ошибке
          invoke GetDlgItem, hwnd, ebx
          invoke SetFocus, eax                  ; установить фокус на окно с ошибкой
finish:
          mov eax,TRUE

        .elseif uMsg == WM_CLOSE                ; закрытие окна
          invoke EndDialog, hwnd, NULL          ; закрыть диалог
          mov eax,TRUE

        .else
          xor eax,eax
        .endif
        ret
DlgProc endp

; Расчёт
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
        jz calc_end                             ; прыгаем, если получился ноль (деление на 0), ошибка

        cdq                                     ; eax -> edx:eax (a*b)
        mov ebx,4
        idiv ebx                                ; a*b/4
        dec eax

        cdq
        idiv ecx                                ; (a*b/4 - 1)/(41-b*a + c)

        inc byte ptr [edi + 4*5]                ; Ok = TRUE

        test eax,1
        jnz odd
        sar eax,1                               ; чётный: делим результат на 2
        jmp calc_end
odd:    imul eax,5                              ; нечётный: умножаем на 5
calc_end:
        stosd                                   ; записываем результат
        add esi,4                               ; к следующему числу
        cmp esi,offset B
        jb calc_next                            ; повторяем

        ret
Calculate endp

end Start
