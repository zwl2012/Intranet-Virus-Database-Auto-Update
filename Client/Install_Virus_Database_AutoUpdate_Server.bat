TITLE  ���˷Ʋ������Զ���������
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
@ echo. ��ӭʹ�����˷Ʋ������Զ���������                              
@ echo. ****************************************************************
@ echo. ��ѡ��Ҫ���в�������ţ�
@ echo.                                                   
@ echo. 1:��װ�������Զ����·���                                                          
@ echo. 2:�鿴�����б�                                                   
@ echo. 3:�������з���                                                   
@ echo. 4:ж�ز�������·��� 
@ echo. q:�˳�                                                          
@ echo. �����Ӧ�����ִ����ز���                                
@ echo.                                                                           

@ echo. Power by   ������
SET /P ST=������: 
if /I "%ST%"=="1" goto Create
if /I "%ST%"=="2" goto List
if /I "%ST%"=="3" goto Run
if /I "%ST%"=="4" goto Remove
if /I "%ST%"=="q" goto EOF
echo ����������������룡
goto :Begin

:Create
@echo off
schtasks /create /tn "McAfee Virus Database Auto Update Server" /ru system /tr "%~dp0start.vbs" /sc daily /st 01:00
start %systemroot%\tasks
echo ���񴴽��ɹ�
pause
goto Begin

:List
schtasks /query
goto Begin

:Run
@echo off
schtasks /run /tn "McAfee Virus Database Auto Update Server"
echo ����ִ�гɹ�
pause
goto Begin


:Remove
schtasks /delete /tn "McAfee Virus Database Auto Update Server" /f
echo ����ж�سɹ�
pause
goto Begin