@echo off
TITLE %~n0 流程开始
echo %~n0 当前工作目录：%~dp0
setlocal enabledelayedexpansion
if not defined Log (
    rem 日志路径
	set Log=%~dp0..\..\log\debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	rem 设置FTP服务IP
	set Address=192.168.5.63
	rem 设置FTP链接用户名
	set FTPUsername=mcafee
	rem 设置FTP链接密码
	set FTPPassword=WU4m5DryqQ4re8
	rem 设置下载路径
	set HistoryUpdate=%~dp0..\..\history\!currentDate!
	rem 获取当前ip
	for /f "tokens=4" %%a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do (set LocalIP=%%a)
)


rem 设置下载文件存放路径
::if not exist %HistoryUpdate% md %HistoryUpdate%

rem 第一个参数 操作文件名
if '%1' EQU '' (
	echo %currentTime% %~n0 输入参数:%1 不合法
	exit /b -1
) else (
	set FileName=%1
	set fullFilePath=%~f1
    set sortFileName=%~xn1
)

rem 第二个参数 操作类型 限定值列表
set methodList='download upload'
echo %methodList% | findstr %2 && set methodType=%2 || set methodType=download

rem 第三个参数 存放目录(下载即本地 上传即远程)
if '%3' NEQ '' (
	if /i %methodType% EQU download ( 
		set savePath=%~f3 
	) else ( 
		SET savePath=%3
		REM 统一路径风格
		SET savePath=!savePath:/=\!
		REM 去除路径中空格
		SET savePath=!savePath: =!
		REM 目录创建兼容
		SET firstchar=!savePath:~0,1!
		SET lastchar=!savePath:~-1!
		IF '!firstchar!' EQU '\' ( SET savePath=!savePath:~1! )
		IF '!lastchar!' EQU '\' ( 
			SET uploadDirectory=!savePath!
			SET savePath=!savePath!!sortFileName!
			SET savePath=!savePath: =!
			SET uploadDirectory=!uploadDirectory:~0,-1!
		) ELSE (
			REM 判断是否需要创建目录
			echo !savePath! | findstr \ > nul && SET uploadDirectory=!savePath:\%~nx3=! || ECHO not required
		)
		
		REM ECHO !firstchar!
		REM ECHO !lastchar!
		

		REM ECHO !savePath!
		REM ECHO !uploadDirectory!
		
		REM PAUSE
		REM GOTO :eof
		REM REM 判断是否指定保存文件名
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
rem 开始进行操作
echo %currentTime% 使用FTP方式下载%sortFileName%至 %savePath%>>  %Log%
set TypeName=下载
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
echo %currentTime% 使用FTP方式上传 %fullFilePath% 至 %savePath%>>  %Log%
set TypeName=上传
set FTPcommand=%TEMP%\ftpup.src
> "%FTPcommand%" (
    echo user %FTPUsername% %FTPPassword%
    echo bin
    REM 预创建存放文件夹
    echo mkdir !uploadDirectory!
    echo put %fullFilePath% %savePath%
    echo bye
)
@echo on
goto :common


:common
set ftpLog=%TEMP%\ftp.log

echo.|ftp -v -n -i -s:"%FTPcommand%" %Address% > %ftpLog%

::输出FTP日志到系统日志
FOR /f "skip=4 delims= eol=b" %%i in (%ftpLog%) DO (
	SET logContent=%%i
	SET logContent=!logContent: =!
	IF '!logContent!' NEQ '' ( ECHO %currentTime% %%i  >> %Log% )
)

rem 解析FTP日志获取错误信息
more %ftpLog% | findstr /ic:"未连接" && set errorInfo=连接FTP服务器失败 || echo zap
more %ftpLog% | findstr /ic:"Not connected" && set errorInfo=链接FTP服务器失败 || echo zap
more %ftpLog% | findstr /ic:"cannot log in" && set errorInfo=身份认证失败 || echo warning
more %ftpLog% | findstr /ic:"找不到文件" && set errorInfo=本地文件不可用 || echo liar
more %ftpLog% | findstr /ic:"File not found" && set errorInfo=请求文件不可用 || echo zombie
more %ftpLog% | findstr /ic:"Access is denied" && set errorInfo=因服务端设置,无权限完成请求的操作 || echo warning
more %ftpLog% | findstr /ic:"Transfer complete." && set successInfo=1 || echo liar

REM del %ftpLog%
del %FTPcommand%

if defined successInfo (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP方式%TypeName% %FileName% 完成 >>  %Log%
	exit /b 0
)
if defined errorInfo (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP方式%TypeName% %FileName% 失败,原因：%errorInfo% >>  %Log%
	exit /b 1
) else (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% FTP方式%TypeName% %FileName% 失败,可能网络链接存在问题，请联系开发者进行处理 >>  %Log%
	exit /b 2
)




