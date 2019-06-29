TITLE  迈克菲病毒库自动升级服务
@ECHO OFF & PUSHD %~DP0 & TITLE
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
:Begin
cls
@ echo. ***************************************************************
@ echo. 欢迎使用迈克菲病毒库自动升级服务                              
@ echo. ****************************************************************
@ echo. 请选择要进行操作的序号：
@ echo.                                                   
@ echo. 1:安装病毒库自动更新服务                                                          
@ echo. 2:查看服务列表                                                   
@ echo. 3:立即运行服务                                                   
@ echo. 4:卸载病毒库更新服务 
@ echo. q:退出                                                          
@ echo. 输入对应序号以执行相关操作                                
@ echo.                                                                           

@ echo. Power by   周望龙
SET /P ST=请输入: 
if /I "%ST%"=="1" goto Create
if /I "%ST%"=="2" goto List
if /I "%ST%"=="3" goto Run
if /I "%ST%"=="4" goto Remove
if /I "%ST%"=="q" goto EOF
echo 输入错误，请重新输入！
goto :Begin

:Create
@echo off
schtasks /create /tn "McAfee Virus Database Auto Update Server" /ru system /tr "%~dp0start.vbs" /sc daily /st 01:00
start %systemroot%\tasks
echo 服务创建成功
pause
goto Begin

:List
schtasks /query
goto Begin

:Run
@echo off
schtasks /run /tn "McAfee Virus Database Auto Update Server"
echo 命令执行成功
pause
goto Begin


:Remove
schtasks /delete /tn "McAfee Virus Database Auto Update Server" /f
echo 服务卸载成功
pause
goto Begin