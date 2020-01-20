@echo off
if "%1"=="" (set opt=/discard) else (set opt=/commit)
if /i "%1"=="c" (set opt=/commit) else (set opt=/discard)
if "%2"=="" (set image=E:) else (set image=%2)
REM if "%2"=="" (set image=D:\WinPE_amd64\media) else (set image=%2)
if "%3"=="" (set mount=D:\WinPE_amd64\mount) else (set mount=%3)

Dism /Mount-Image /ImageFile:%image%\sources\boot.wim /index:1 /MountDir:%mount%
pause 
if "%opt%" EQU "/discard" (type %mount%\Windows\System32\Startnet.cmd) else (
echo ergaenze Startnet.cmd
(
echo.@set pattern=\StartWinPE.cmd
echo.@set DRIVE=no
echo @set drives=Z Y X W V U T S R Q P O N M L K J I H G F E D C
echo @for %%%%a in ^(%%drives%%^) do @if exist %%%%a:%%pattern%% set DRIVE=%%%%a
echo.@if %%DRIVE%% NEQ no @start %%DRIVE%%:%%pattern%%
) >> %mount%\Windows\System32\Startnet.cmd
REM ) >> Startnet.cmd
)
pause 
Dism /Unmount-Image /MountDir:%mount% %opt%
