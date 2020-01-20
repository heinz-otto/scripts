@if "%1" == "" goto usage 
md %1
copy %2\System32\Recovery\winre.wim %1\winre.wim
%2\System32\reagentc /setreimage /path %1 /target %2
goto end
:usage
@echo MakeRecovery R:\Recovery\WindowsRE W:\Windows
:end