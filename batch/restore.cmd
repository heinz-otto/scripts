@echo off & setlocal
REM image auswaehlen
set image=backup.wim
REM Setze das Partitionsschema BIOS oder UEFI
set PART=UEFI

@echo list disk|diskpart
@echo Welche Disk soll neu gemacht werden?
REM Eingabe Schleife
REM Diese ungefaehrliche Vorbelegung, falls einfach Enter betaetigt wird.
set Eingabe=x
:Loop
set /P Eingabe="Die Disk wird komplett geloescht, bitte Nr bestaetigen (x Abbruch): "
set "zeichen=%Eingabe:~0,1%" & REM Erstes Zeichen extrahieren
set /a "nummer=%zeichen%" & REM und als Zahl Åbergeben
if %zeichen% == %nummer% goto :prog1
if /i %zeichen%==x goto :eof
Echo Falsche Eingabe "%Eingabe%" erstes Zeichen %zeichen% - Bitte nur 0-9 eingeben oder X fÅr Abbrechen
if %zeichen% NEQ %nummer% goto :Loop
goto :Loop

REM Hauptprogramm
:prog1
REM finde das niedrigste Laufwerk mit einem wim Pfad
Call findelw \wim
set wim=%drive%:\wim

echo Erzeuge Partitionen im %PART% Style
diskpart /s CreatePartitions-%PART%.txt
echo restore von Image: %wim%\%image%
dism /Apply-Image /ImageFile:%wim%\%image% /Index:1 /ApplyDir:W:\
bcdboot W:\Windows /s S:
md R:\Recovery\WindowsRE
copy %wim%\winre.wim R:\Recovery\WindowsRE\winre.wim
W:\Windows\System32\reagentc /setreimage /path R:\Recovery\WindowsRE /target W:\Windows

wpeutil shutdown    