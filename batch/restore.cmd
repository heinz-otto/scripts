@echo off & setlocal
REM Diese Script stellt eine Windows System Disk komplett mit Neupartitionierung und Image wieder her
REM image auswaehlen
set image=backup.wim
if not "%1"=="" set image=%1.wim
REM Setze das Partitionsschema BIOS oder UEFI
set PART=UEFI
if not "%2"=="" set PART=%2

@echo list disk|diskpart
@echo Welche Disk soll neu gemacht werden?
REM Eingabe Schleife
REM Diese ungefaehrliche Vorbelegung, falls einfach Enter betaetigt wird.
set Eingabe=x
:Loop
set /P Eingabe="Die Disk wird komplett geloescht, bitte Nr bestaetigen (x Abbruch): "
set "zeichen=%Eingabe:~0,1%" & REM Erstes Zeichen extrahieren
set /a "nummer=%zeichen%" & REM und als Zahl uebergeben
if %zeichen% == %nummer% goto :prog1
if /i %zeichen%==x goto :eof
Echo Falsche Eingabe "%Eingabe%" erstes Zeichen %zeichen% - Bitte nur 0-9 eingeben oder X fuer Abbrechen
if %zeichen% NEQ %nummer% goto :Loop
goto :Loop

REM Hauptprogramm
:prog1
REM finde das niedrigste Laufwerk mit einem wim Pfad
Call findelw \wim
set wim=%drive%:\wim

REM diskpart /s CreatePartitions-%PART%.txt
REM Bediene diskpart über Pipeline und ersetze select disk 0 durch eingegebene Disknummer
echo Erzeuge Partitionen auf Disk %nummer% im %PART% Partition Style
echo Druecke eine Taste fuer weiter oder ctrl+c fuer abbruch
pause
(echo sel disk %nummer% & type CreatePartitions-%PART%.txt|find /v /i "select disk 0")|find /v /i "rem "|diskpart
echo restore von Image: %wim%\%image%
dism /Apply-Image /ImageFile:%wim%\%image% /Index:1 /ApplyDir:W:\
echo erzeuge Boot System auf Laufwerk S:
bcdboot W:\Windows /s S:
echo erzeuge Recovery auf Laufwerk R:
md R:\Recovery\WindowsRE
copy %wim%\winre.wim R:\Recovery\WindowsRE\winre.wim
W:\Windows\System32\reagentc /setreimage /path R:\Recovery\WindowsRE /target W:\Windows
echo Druecke eine Taste für shutdown
pause
wpeutil shutdown
