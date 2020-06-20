@echo off
..\rc\sircc32 lab5.rc
\masm32\bin\ml /c /Cp /Fl lab5.asm
\masm32\bin\link /subsystem:windows lab5.obj lab5.res
