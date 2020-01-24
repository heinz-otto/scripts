@echo off & setlocal
REM Diese Script stellt eine Windows System Disk komplett mit Neupartitionierung und Image wieder her
REM setze den Imagenamen
set image=backup.wim
REM finde die Laufwerke anhand von Pfaden, der niedrigste Buchstabe wir gefunden
call findelw.cmd \windows
set cdir=%drive%
call findelw.cmd \wim
set wdir=%drive%:\wim
REM Aufzeichnung des Image
dism /capture-image /imagefile:%wdir%\%image% /capturedir:%cdir%: /name:%cdir%-WinOS