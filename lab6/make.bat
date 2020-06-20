@echo off
..\rc\sircc32 lab6.rc
\masm32\bin\ml /c /Cp /Fl lab6.asm
\masm32\bin\link /subsystem:windows lab6.obj lab6.res
