::2019��5��5��
@echo off
TITLE �������˷Ʋ������������

::Ĭ�ϲ���
rem ��ǰ·������
set currentPath=%~dp0
rem ��Ŀ��Ŀ¼(����ǰ�ļ��ĸ���Ŀ¼)
set mainPath=%currentPath%..\
rem �����ļ�·��
set configPath=%mainPath%config\
rem ��ǰģ�������ļ�
set commonConfig=%configPath%common.ini

rem ��־����ļ���
set logPath=%mainPath%log\
rem ��־���·��
set Log=%logPath%%date:~0,4%-%date:~5,2%-%date:~8,2%.log

rem Դ�б����·��
set temPath=%mainPath%tmp\
rem �����ļ����·��
set updateSavePath=%mainPath%history\%date:~0,4%-%date:~5,2%-%date:~8,2%\
rem �����б����·��
set currentUpdate=%updateSavePath%update.list
rem �����б���ʱ���
set tempSourceList=%temPath%update.list
rem ��һ�θ���Դ�ļ�
set lastUpdate=%temPath%last.update

rem �����ļ���
set DriveLibraryPath=%mainPath%drive\
rem ��������
set transferDrive=%DriveLibraryPath%transfer\FTP.bat
rem ��֤����
set validationDrive=%DriveLibraryPath%validation\hash.bat
set signatureCheckDrive=%DriveLibraryPath%validation\signature.bat
rem ��װ����
set installDrive=%DriveLibraryPath%install\install.bat

rem ��������
REM ȫ������״̬��ʶ��
SET isSuccess=1
set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%

SET updateTotalLength=0


echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��ʼ����ϵͳ��ȫ�������� >> %Log%
rem Ĭ��IPֵ
set LocalIP=169.254.254.254
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% Ĭ��IPֵΪ %LocalIP% >> %Log%
rem �������ʱ��
set /a StaggerTime=%RANDOM%%%300
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% Ĭ�ϴ���ʱ��Ϊ %StaggerTime% >> %Log%

rem ���������ļ�
:LoadConfig
for /f "tokens=1-2 delims==" %%i in (%commonConfig%) do (
    ECHO %%i | findstr # && set comment=1 || echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ���� %%i ���� >> %Log%
    if '%%j' neq '' set %%i=%%j
)
if not defined Address (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����ļ���Ч >> %Log%
    SET isSuccess=0
    GOTO :Fail
)


:PreInitial
md %updateSavePath% >nul 2>nul
del /f /q %tempSourceList% >nul 2>nul

::��ȡIP��ַ
:UpdateLocalIP
setlocal enabledelayedexpansion
ver | FINDSTR "5\.[0-9]\.[0-9][0-9]*" > NUL && SET xp=1
set Index=1
if '%xp%' EQU '1' (
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find /i "IP Address"') do (
        if !Index! EQU %NicOrder% (
            set IP=%%a
            set "IPS=!IP: =!"
            set LocalIP=!IPS!
        )
        set /a Index+=1
    )
) else (
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find /i "IPv4"') do (
        if !Index! EQU %NicOrder% (
            set IP=%%a
            set "IPS=!IP: =!"
            set LocalIP=!IPS!
        )
        set /a Index+=1
    )
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% IPֵ����Ϊ: %LocalIP% >> %Log%

:UpdateStaggerTime
setlocal enabledelayedexpansion
for /f "tokens=4 delims=." %%a in ("%LocalIP%") do (
    SET id=%%a
    set /a StaggerTime=%Deadline%*3600/255
    set /a StaggerTime=!StaggerTime!*!id!
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% ����ʱ�����Ϊ !StaggerTime! >> %Log%
::������ʼ�� ׼������ͬ���׶�
:EndInitial
if /i '%Protocol%' EQU 'FTP' (
    goto :FTPTransfer
) else (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��Э���ݲ���֧�֣����������֧�ֵ�Э�顣 >> %Log%
    goto :EOF
)

::�ļ�����׶�
:FTPTransfer
setlocal enabledelayedexpansion
call %transferDrive% %SourceList% download %temPath%
if %errorlevel% NEQ 0 (
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ����Դ����ʧ�ܣ����黷�������ԣ� >> %Log%
	goto :Fail
)
copy /b /y %tempSourceList% %currentUpdate%

rem ��ȡ�����ļ�hash
call %validationDrive% %currentUpdate% > %TEMP%\newHash
call %validationDrive% %lastUpdate% > %TEMP%\oldHash
set /p currentUpdateHash=<%TEMP%\newHash
set /p lastUpdateHash=<%TEMP%\oldHash

echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��ǰԴ Hash�� !currentUpdateHash! �ϴ�Դ Hash:  !lastUpdateHash! >> %Log%

rem �ж��Ƿ����ϴθ������
if '%currentUpdateHash%' NEQ '%lastUpdateHash%' (
    if '%currentUpdateHash%' EQU 'null' (
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% Դ��������ʧ�ܣ�������¡� >> %Log%
        SET isSuccess=0
        goto :Fail
    ) else (
        ::�������ʱ����־
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����������صȴ�ʱ��: !StaggerTime! �� >>  %Log%
        set StaggerTime=15
        ping -n !StaggerTime! 127.1 > nul
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����������صȴ���ɣ����и������� >>  %Log%
        for /f "tokens=1-3 delims= " %%i in (%currentUpdate%) do (
            call %transferDrive% %%i download %updateSavePath%
            if %errorlevel% EQU 0 set /a updateTotalLength+=%%k
        )
    )
) else (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ���θ������ϴθ���һ�£�������¡� >> %Log%
    goto :Clean
)
rem д����־
set /a humanSize=%updateTotalLength%/1024/1024
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ���θ����ļ�����Ϊ��%humanSize%M >>  %Log%
GOTO :Validation

:Validation
cd /d %updateSavePath%
setlocal enabledelayedexpansion
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��������ļ�У������,��ǰ����Ŀ¼: %CD% >>  %Log%
for /f "tokens=1 delims= " %%i in (%currentUpdate%) do (
    ::��ȡ�ļ���
    set fileName=%%~xni
    set fileFullPath=%updateSavePath%%%~xni
    ::��ȡ�ļ�hashֵ
    call %validationDrive% !fileFullPath! > %TEMP%\hash_result
    set /p fileHash=< %TEMP%\hash_result
    ::��ȡ�ļ�����
    FOR /F 'usebackq' %%q IN ( '!fileFullPath!' ) DO set fileSize=%%~zq

    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �ļ���:!fileName! Hash: !fileHash! Size: !fileSize! >> %Log%
    findstr /i !fileSize! %currentUpdate% > NUL && set sizeOK=1
    findstr /i !fileHash! %currentUpdate% > NUL && set hashOK=1
    if DEFINED sizeOK (
		IF DEFINED hashOK (
			echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����ļ� !fileName! ��������ļ�һ�¡� >> %Log%
      	) else (
      		SET isSuccess=0
      		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ���紫������� !fileName! HashУ��δͨ���� >> %Log%
      	)
    ) else (
    	SET isSuccess=0
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����ļ� !fileName! ���ز������� >> %Log%
    )
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �����ļ�У����ϣ�׼�����а�װ���� >>  %Log%
goto :Install


:Install
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ��������ļ���װ����,��ǰ����Ŀ¼: %CD% >>  %Log%
for /f "tokens=1 delims= " %%a in (%currentUpdate%) do (
	set updateName=%%~xna
	SET updateFullPath=%updateSavePath%%%~xna
	IF %CheckDigitalSignature% EQU 1 (
		ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time �����û����ü������ļ�����ǩ����� >> %Log%
		CALL %signatureCheckDrive% !updateFullPath!
		IF !errorlevel! NEQ 0 (
            ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time �����ļ�%updateName%����ǩ�������� >> %Log%
			SET signcheckerror=1
			SET isSuccess=0
		)
	)
	IF NOT DEFINED signcheckerror (
		ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time ׼����װ !updateName! ����,���Ժ� >> %Log%
		call %installDrive% !updateFullPath!
		IF !errorlevel! NEQ 0 SET isSuccess=0
	)
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time ���� !updateName! ��װ�������. >> %Log%
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ���и����ļ���װ���������! >>  %Log%
CD /d %mainPath%
goto :Success
endlocal

:Success
IF %isSuccess% EQU 1 (
	del %lastUpdate%
	move %tempSourceList% %lastUpdate%
)
call :UPLOG
call :Clean
exit /b 0

:Fail
rd /s /q %updateSavePath%
call :UPLOG
call :Clean
exit /b 2

:UPLOG
setlocal enabledelayedexpansion
IF defined LogReport (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% ׼���ϴ�������־�� >> %Log%
	IF '%LogReport%' EQU '1' (
		if '%isSuccess%' EQU '1' (
			REM ��־�ϴ�Ԥ����
			call %transferDrive% %Log% upload Log\%date:~0,4%-%date:~5,2%-%date:~8,2%\%LocalIP%.log
		) ELSE (
			call %transferDrive% %Log% upload Log\%date:~0,4%-%date:~5,2%-%date:~8,2%\%LocalIP%-Fail.log
		)
	)
) ELSE (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% �û����������ϴ���־�� >>  %Log%
)

:Clean
del /q %TEMP%newHash
del /q %TEMP%oldHash
del /q %TEMP%\hash_result
del /q %tempSourceList%

