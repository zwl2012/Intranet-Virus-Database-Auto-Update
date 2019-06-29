@echo off
TITLE %~n0 ���̿�ʼ
echo %~n0 ��ǰ����Ŀ¼��%~dp0
setlocal enabledelayedexpansion
if not defined Log (
    rem ��־·��
	set Log=%~dp0..\..\log\debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	rem ����FTP����IP
	set Address=192.168.5.63
	rem ����FTP�����û���
	set FTPUsername=mcafee
	rem ����FTP��������
	set FTPPassword=WU4m5DryqQ4re8
	rem ��������·��
	set HistoryUpdate=%~dp0..\..\history\!currentDate!
	rem ��ȡ��ǰip
	for /f "tokens=4" %%a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do (set LocalIP=%%a)
)


rem ���������ļ����·��
::if not exist %HistoryUpdate% md %HistoryUpdate%

rem ��һ������ �����ļ���
if '%1' EQU '' (
	echo %currentTime% %~n0 �������:%1 ���Ϸ�
	exit /b -1
) else (
	set FileName=%1
	set fullFilePath=%~f1
    set sortFileName=%~xn1
)

rem �ڶ������� �������� �޶�ֵ�б�
set methodList='download upload'
echo %methodList% | findstr %2 && set methodType=%2 || set methodType=download

rem ���������� ���Ŀ¼(���ؼ����� �ϴ���Զ��)
if '%3' NEQ '' (
	if /i %methodType% EQU download ( 
		set savePath=%~f3 
	) else ( 
		SET savePath=%3
		REM ͳһ·�����
		SET savePath=!savePath:/=\!
		REM ȥ��·���пո�
		SET savePath=!savePath: =!
		REM Ŀ¼��������
		SET firstchar=!savePath:~0,1!
		SET lastchar=!savePath:~-1!
		IF '!firstchar!' EQU '\' ( SET savePath=!savePath:~1! )
		IF '!lastchar!' EQU '\' ( 
			SET uploadDirectory=!savePath!
			SET savePath=!savePath!!sortFileName!
			SET savePath=!savePath: =!
			SET uploadDirectory=!uploadDirectory:~0,-1!
		) ELSE (
			REM �ж��Ƿ���Ҫ����Ŀ¼
			echo !savePath! | findstr \ > nul && SET uploadDirectory=!savePath:\%~nx3=! || ECHO not required
		)
		
		REM ECHO !firstchar!
		REM ECHO !lastchar!
		

		REM ECHO !savePath!
		REM ECHO !uploadDirectory!
		
		REM PAUSE
		REM GOTO :eof
		REM REM �ж��Ƿ�ָ�������ļ���
		REM ECHO %uploadDirectory:~-1% 999999999 >> %Log%
		REM IF !uploadDirectory:~-1! EQU '\' (
		REM 	set savePath=!uploadDirectory!%sortFileName%
		REM ) ELSE (
		REM 	set savePath=!uploadDirectory!\%sortFileName%
		REM )
		REM ECHO !savePath! 88888888 >> %Log%
	)
) ELSE (
		SET uploadDirectory=\
		SET savePath=\!sortFileName!
)

if /i %methodType% EQU download goto :download
if /i %methodType% EQU upload goto :upload


:download
rem ��ʼ���в���
echo %currentTime% ʹ��FTP��ʽ����%sortFileName%�� %savePath%>>  %Log%
set TypeName=����
cd /d %savePath%
set FTPcommand=%TEMP%\ftp.src
> "%FTPcommand%" (
    echo user %FTPUsername% %FTPPassword%
    echo bin
    echo get %FileName%
    echo bye
)
@echo on
goto :common


:upload
echo %currentTime% ʹ��FTP��ʽ�ϴ� %fullFilePath% �� %savePath%>>  %Log%
set TypeName=�ϴ�
set FTPcommand=%TEMP%\ftpup.src
> "%FTPcommand%" (
    echo user %FTPUsername% %FTPPassword%
    echo bin
    REM Ԥ��������ļ���
    echo mkdir !uploadDirectory!
    echo put %fullFilePath% %savePath%
    echo bye
)
@echo on
goto :common


:common
set ftpLog=%TEMP%\ftp.log

echo.|ftp -v -n -i -s:"%FTPcommand%" %Address% > %ftpLog%

::���FTP��־��ϵͳ��־
FOR /f "skip=4 delims= eol=b" %%i in (%ftpLog%) DO (
	SET logContent=%%i
	SET logContent=!logContent: =!
	IF '!logContent!' NEQ '' ( ECHO %currentTime% %%i  >> %Log% )
)

rem ����FTP��־��ȡ������Ϣ
more %ftpLog% | findstr /ic:"δ����" && set errorInfo=����FTP������ʧ�� || echo zap
more %ftpLog% | findstr /ic:"Not connected" && set errorInfo=����FTP������ʧ�� || echo zap
more %ftpLog% | findstr /ic:"cannot log in" && set errorInfo=������֤ʧ�� || echo warning
more %ftpLog% | findstr /ic:"�Ҳ����ļ�" && set errorInfo=�����ļ������� || echo liar
more %ftpLog% | findstr /ic:"File not found" && set errorInfo=�����ļ������� || echo zombie
more %ftpLog% | findstr /ic:"Access is denied" && set errorInfo=����������,��Ȩ���������Ĳ��� || echo warning
more %ftpLog% | findstr /ic:"Transfer complete." && set successInfo=1 || echo liar

REM del %ftpLog%
del %FTPcommand%

if defined successInfo (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP��ʽ%TypeName% %FileName% ��� >>  %Log%
	exit /b 0
)
if defined errorInfo (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP��ʽ%TypeName% %FileName% ʧ��,ԭ��%errorInfo% >>  %Log%
	exit /b 1
) else (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP��ʽ%TypeName% %FileName% ʧ��,�����������Ӵ������⣬����ϵ�����߽��д��� >>  %Log%
	exit /b 2
)



