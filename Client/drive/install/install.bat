::���°�װģ��
::����:2019��5��15��
::@ECHO OFF
TITLE �������°�װ����

if not defined Log (
	set Log=%~dp0debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log
)

::Mcafee������
set exeArg=-silent -logfile
::΢����װ��
set msuArg=/quiet /norestart /verbose

set installFile=%~f1
set installFileName=%~nx1
REM �ļ�ȫ��Ϊ: %~xn1, �ļ���Ϊ�� %~n1, ��չ��Ϊ�� %~x1
set installFileType=%~x1
set exeInstall=0
set msuInstall=0
set installFlag=0
set installType=���������

SET installLog=%TEMP%installLog

setlocal enabledelayedexpansion

echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ������°���װ���̡� >> %Log%
if "%installFileType%"==".exe" ( set exeInstall=1 )
if "%installFileType%"==".msu" ( set msuInstall=1 )

if %exeInstall% EQU 1 (
	%installFile% %exeArg% %installLog%
	if '!errorlevel!' neq '0'  set installFlag=!errorlevel!
) else (
	if %msuInstall% EQU 1 (
		set installType=ϵͳ����
		%installFile% %msuArg% >> %Log%
		if '!errorlevel!' neq '0'  set installFlag=!errorlevel!
	)
)
::������־
for /f "eol= tokens=5 delims=	" %%i in (%installLog%) do (
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %%i >> %Log%
)
DEL /f /q %installLog%
if %installFlag% EQU 0 (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType% : %installFileName% ����Ѱ�װ�ɹ��� >> %Log%
	exit /b %installFlag%
) else (
	if %installFlag% == 43 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% ��װʧ�ܣ���ǰ�����δ�ҵ�����������Mcafee��Ʒ�� >> %Log%
		exit /b 1
	)
	if %installFlag% == 2359302 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% ������Ѱ�װ��ǰ���¡� >> %Log%
		exit /b 0
	)
	if %installFlag% == -2145124329 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��ǰ%installType%:%installFileName% �����޷���װ����ǰ������� >> %Log%
		exit /b 1
	)
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% �����δ�ܳɹ���װ��ǰ���¡� >> %Log%
	exit /b 1
)