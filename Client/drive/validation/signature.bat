::����ǩ��У��ģ��
::����:2019��6��10��

@echo off
if not defined Log (
	set currentPath=%~dp0
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
    set LogPath=%~dp0..\..\log
	set Log=%~dp0..\..\log\debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log

	::�ӵ��ı����ӳ�
	md %LogPath% >nul 2>nul
)
SET signatureCheckDrive=%~dp0sigcheck.exe

rem ����У��
if "%~1" EQU "" set err=1
if "%~1" EQU " " set err=1
if not exist %~f1 set err=1
if defined err (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %~n0 �������:%1 ���Ϸ�
	exit /b -1
) else (
	set inputFile=%~xn1
	set fileFullPath=%~f1
)

echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��ʼ���ļ� %inputFile% ����ǩ��У�����̡� >> %Log%
setlocal enabledelayedexpansion
set tempINFO=%TEMP%\%~n0.info
%signatureCheckDrive% -q -h %fileFullPath% > %tempINFO%
set installFlag=!errorlevel!
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %inputFile%ǩ��У����: >> %Log%
for /f "tokens=1-3 skip=1 eol=F delims=	" %%i in (%tempINFO%) do (
	SET key=%%i
	SET key=!key::=!
	SET value=%%j
	SET value=!value: =!
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time% !key!:!value! >> %Log%
)

del /f /q %tempINFO%

if %installFlag% EQU 0 (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �ļ�:%inputFile% ǩ�������� >> %Log%
	exit /b %installFlag%
) else (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �ļ���%inputFile% ����ǩ���𻵻�δǩ���� >> %Log%
	exit /b %installFlag%
)