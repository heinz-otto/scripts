@ECHO off
REM dieses Script ist der Rumpf fuer den erweiterten Start von Windows PE
REM der Name StartWinPE wird ueber WinPEmount ins WinPE Image "eingebrannt"
REM wechsel in Laufwerk und Pfad des Scripts
cd /D %~dp0
REM Deutsche Tastatur setzen
wpeutil SetKeyboardLayout 0407:00000407
REM starte weitere Prozesse und behalte dieses "lokalisierte" Fenster 
echo on
REM start call restore.cmd
start
