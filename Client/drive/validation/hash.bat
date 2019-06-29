@echo off
TITLE %~n0 �������̿�ʼ
if not defined Log (
    echo δ����Log����
	set currentPath=%~dp0
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
    set LogPath=%~dp0..\..\log
	set Log=%~dp0..\..\log\debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log

	::�ӵ��ı����ӳ�
	md %LogPath% >nul 2>nul
)

::��ϣĬ��ֵ
set hashVal=null

echo %currentTime% ��ʼ�� %~f1 �����ļ���ϣֵУ�顣 >> %Log%

setlocal enabledelayedexpansion
::·������
set source=%~xf1

::�������
if '%~1' == '' set err=1
if '%~1' == ' ' set err=1
if not exist %source%  set err=2
if defined err (
	if !err! equ 2 (
		echo %currentTime% %~n0 �������ļ�·��������,�˳�Hash���� >> %Log%
	) else (
		echo %currentTime% %~n0 ����������Ϸ�,�˳�����Hash���� >> %Log%
	)
    exit /b -1
)

::��ϵͳ����(Ĭ��ϵͳ·��)
set certutil=%windir%\certutil.exe
set xp_path=%certutil%
set win7path=%windir%\System32\certutil.exe

if not exist %xp_path% if not exist %win7path% (
   set certutil=%~dp0certutil\certutil.exe
) else (
   set certutil=%win7path%
)

rem ����ݿ��� �ʽ���������hash��ʽ
rem set methodList='MD5 SHA1 SHA256'
rem echo %methodList% | findstr %2 &&  set hashType=%2 || set hashType=SHA1

:: ��ʱ�ļ�
set hashTEMP=%TEMP%\%currentDate%-hash.info

%certutil% -hashfile %source% > %hashTEMP%
for /f "tokens=* delims=" %%i in (%hashTEMP%) do (
	set /a n+=1 & if !n!==2 set "hashVal=%%i"
)

rem Ϊ����win8����ϵͳ��� �����¹�ϣֵ�������
set hashVal=!hashVal: =!
echo !hashVal! | findstr 'certutil' && set error=1 || set success=1

del /f /q %hashTEMP%

echo %hashVal%

if defined success (
    echo %currentTime% �ļ� %~xn1 ��HASHֵ:!hashVal! >> %Log%
    exit /b 0
) else (
    echo %currentTime% �ļ� %~xn1 ��HASHֵ��ȡʧ�ܣ��ļ������� >> %Log%
    exit /b 1
)
