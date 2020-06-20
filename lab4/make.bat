@echo off
..\rc\sircc32 lab4.rc
\masm32\bin\ml /c /Cp /Fl lab4.asm
\masm32\bin\link /subsystem:windows lab4.obj lab4.res
\masm32\bin\ml /c /Cp /Fl lab4-2.asm
\masm32\bin\link /subsystem:windows lab4-2.obj lab4.res
