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

DlgProc         proto   hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
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
IDC_EDT21 = 1021
IDC_EDT22 = 1022
IDC_EDT23 = 1023
IDC_EDT24 = 1024
IDC_EDT25 = 1025
IDC_STC1 = 1026
IDC_STC2 = 1027
IDC_STC3 = 1028
IDC_STC4 = 1029
IDC_STC5 = 1030
IDC_BTN1 = 1031
IDC_STC6 = 1032

;-- Данные -------------------------------------------------------------------------------------------------------------

.DATA

ErrorText       db 'Ошибка: неверное число либо число = 0 или 1.',0
ErrorTitle      db 'Error',0
ErrorResult     db 'ZeroDiv',0

fmtFP           db '%f',0
_4              dd 4.0
_12             dd 12.0

;-- Неинициализированные данные ----------------------------------------------------------------------------------------

.DATA?

; Значения переменных из диалогового окна и результаты расчётов
A       dq 5 dup (?)
B       dq 5 dup (?)
C_      dq 5 dup (?)
D       dq 5 dup (?)
Result  dt 5 dup (?)                            ; результаты
Ok      dt 5 dup (?)                            ; 1 в младшем байте, если результат корректен

Buf     db 100 dup (?)                          ; буфер для текстового представления числа
Double  dq ?                                    ; промежуточное число

.CODE

;-- Главная процедура --------------------------------------------------------------------------------------------------
Start:
        finit                                   ; инициализация сопроцессора
        invoke GetModuleHandle, NULL            ; получаем хендл текущего модуля
        invoke DialogBoxParam, eax, IDD_MAIN, HWND_DESKTOP, addr DlgProc, NULL ; создаём диалоговое окно (которое описано в ресурсах)
        invoke ExitProcess, NULL                ; выходим из программы

;-- Обработчик сообщений диалога ---------------------------------------------------------------------------------------
DlgProc         proc    uses ebx esi edi, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        .if (uMsg == WM_COMMAND) && (wParam == BN_CLICKED shl 10h + IDC_BTN1) ; нажатие кнопки "OK"
          ; Чтение данных
          mov ebx,IDC_EDT1                      ; id первого окна данных
          mov edi,offset A                      ; адрес переменной
        get_next:
          invoke GetDlgItemText, hwnd, ebx, addr Buf, sizeof Buf ; читаем числовое знаковое значение из окна ввода ebx
          invoke crt_atof, addr Buf             ; преобразуем строку в число, результат в st(0)
          ftst                                  ; сравниваем с 0
          fstsw ax
          sahf
          jz error_val                          ; 0 или неверное значение
          fld1
          fcomp                                 ; сравниваем с 1
          fstsw ax
          sahf
          jz error_val                          ; 1
          fstp qword ptr [edi]                  ; записываем прочитанное значение
          inc ebx                               ; к следующему окну
          add edi,8                             ; к следующему числу
          cmp ebx,IDC_EDT20
          jbe get_next                          ; переходим к следующему

          ; Вычисление
          invoke Calculate

          ; Вывод результата
          mov esi,offset Result                 ; адрес результата
        set_next:
          cmp byte ptr [esi + 10*5],1           ; Ok
          jne wrong                             ; прыгаем, если результат НЕверный
          fld tbyte ptr [esi]                   ; загружаем число
          fstp Double                           ; выгружаем как Double
          invoke crt__snprintf, addr Buf, sizeof Buf, addr fmtFP, dword ptr [Double], dword ptr [Double+4]
          invoke SetDlgItemText, hwnd, ebx, addr Buf ; выводим результат
          jmp r_ok
wrong:    invoke SetDlgItemText, hwnd, ebx, addr ErrorResult ; выводим ошибку
r_ok:     inc ebx                               ; к следующему окну
          add esi,10                            ; к следующему числу
          cmp ebx,IDC_EDT25
          jbe set_next                          ; переходим к следующему
          jmp finish

        ; Сообщение об ошибке и завершение
error_val:
          fstp st(0)                            ; удаляем число из стека FPU
          invoke MessageBox, 0, addr ErrorText, addr ErrorTitle, MB_OK or MB_ICONWARNING ; сообщение о ошибке
          invoke GetDlgItem, hwnd, ebx
          invoke SetFocus, eax                  ; установить фокус на окно с ошибкой
finish:
          mov   eax,TRUE

        .elseif uMsg == WM_CLOSE                ; закрытие окна
          invoke EndDialog, hwnd, NULL          ; закрыть диалог
          mov eax,TRUE

        .else
          xor eax,eax
        .endif
        ret
DlgProc endp

; Расчёт
Calculate proc uses esi edi
        mov esi,offset A
        mov edi,offset Result
calc_next:
        ; (tg(a+c/4) - 12*d) / (a*b-1)
        mov byte ptr [edi + 10*5],0             ; Ok = FALSE

        fld qword ptr [esi]                     ; a
        fmul qword ptr [esi + 8*5]              ; a*b
        fld1
        fsubp                                   ; a*b-1

        ftst                                    ; сравниваем с 0
        fstsw ax
        sahf
        je calc_end                             ; ошибка, если = 0 (деление на 0)

        fld qword ptr [esi + 8*5*2]             ; c
        fdiv _4                                 ; c/4
        fadd qword ptr [esi]                    ; a+c/4
        fptan
        fdiv                                    ; tg(a+c/4)

        fld qword ptr [esi + 8*5*3]             ; d
        fmul _12                                ; 12*4
        fsubp                                   ; tg(a+c/4) - 12*d

        fdivrp                                  ; (tg(a+c/4) - 12*d) / (a*b-1)

        inc byte ptr [edi + 10*5]               ; Ok = TRUE
calc_end:
        fstp tbyte ptr [edi]                    ; записываем результат
        add esi,8                               ; к следующим исходным значениям
        add edi,10                              ; к следующему результату
        cmp esi,offset B
        jb calc_next                            ; повторяем

        ret
Calculate endp

end Start
