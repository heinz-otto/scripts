@REM wechsel in Laufwerk und Pfad des Scripts
cd /D %~dp0
call netz.cmd
wpeutil SetKeyboardLayout 0407:00000407
start call findelw.cmd "\windows"