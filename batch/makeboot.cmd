@if "%1" == "" goto usage 
bcdboot %1 /s %2
goto end
:usage
@echo Nichts passiert: Parameter fehlen, bitte so verwenden
@echo makeboot W:\Windows S:
:end