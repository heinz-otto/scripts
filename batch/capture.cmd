@echo off & setlocal
REM Diese Script erstellt von einer Windows System Disk ein wim Image
REM Ein laufwerk mit dem Ordner \wim muss existieren
REM setze den Imagenamen auf backup oder Aufruf Argument
set image=backup.wim
if not "%1"=="" set image=%1.wim
REM finde die Laufwerke anhand von Pfaden, der niedrigste Buchstabe wir gefunden
call findelw.cmd \windows
set cdir=%drive%
call findelw.cmd \wim
set wdir=%drive%:\wim
REM Aufzeichnung des Image
dism /capture-image /imagefile:%wdir%\%image% /capturedir:%cdir%: /name:%cdir%-WinOS
