@echo off
TITLE ��ϣУ��
if not defined Log (
	set currentPath=%~dp0
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
    	set LogPath=%~dp0log
	set Log=%LogPath%\%date:~0,4%-%date:~5,2%-%date:~8,2%.log
	

	::�ӵ��ı����ӳ�
	md !LogPath! >nul 2>nul
)

::��ϣĬ��ֵ
set hashVal=null

echo %currentTime% ��ʼ�� %~xn1 �����ļ���ϣֵУ�����̡� >> %Log%

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
set hashTEMP=%TMP%\%currentDate%-hash.info

%certutil% -hashfile %source% > %hashTEMP%
for /f "tokens=* delims=" %%i in (%hashTEMP%) do (
	set /a n+=1 & if !n!==2 set "hashVal=%%i"
)

rem Ϊ����win8����ϵͳ��� �����¹�ϣֵ�������
set hashVal=!hashVal: =!
echo !hashVal! | findstr 'certutil' && set error=1 || set success=1

del /f /q %hashTEMP%

if defined success (
    echo %hashVal%
    echo %currentTime% �ļ� %~f1 ��HASHֵΪ:!hashVal! >> %Log%
    exit /b 0
) else (
    echo %hashVal%
    echo %currentTime% �ļ� %~f1 ��HASHֵ��ȡʧ�ܣ��ļ������� >> %Log%
    exit /b 1
)
