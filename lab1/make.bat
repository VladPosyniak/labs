@echo off
..\rc\sircc32 lab1.rc
\masm32\bin\ml /c /Cp /Fl lab1.asm
\masm32\bin\link /subsystem:windows lab1.obj lab1.res
