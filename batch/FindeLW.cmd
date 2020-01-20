@REM Finde Laufwerk mit DOS Mitteln.
@echo Find a drive that has a folder titled %1.
@set pattern=%1
@set DRIVE=no
@REM The last one matched -> the order of letters is important!
@set drives=Z Y X W V U T S R Q P O N M L K J I H G F E D C
@REM forward set drives=C D E F G H I J K L M N O P Q R S T U V W X Y Z
@for %%a in (%drives%) do @if exist %%a:%pattern% set DRIVE=%%a
@if %DRIVE% NEQ no @echo The %pattern% File/Folder is on drive: %DRIVE%
@if %DRIVE%:==%SYSTEMDRIVE% echo The searched Drive %DRIVE% is Systemdrive
@echo Systemdrive is %SYSTEMDRIVE%
@REM @if %DRIVE% NEQ no @dir %DRIVE%:%pattern% /w
@REM @if %DRIVE% NEQ no @start %DRIVE%:%pattern%
