::2019年5月5日
@echo off
TITLE 启动迈克菲病毒库更新流程

::默认参数
rem 当前路径参数
set currentPath=%~dp0
rem 项目主目录(即当前文件的父级目录)
set mainPath=%currentPath%..\
rem 配置文件路径
set configPath=%mainPath%config\
rem 当前模块配置文件
set commonConfig=%configPath%common.ini

rem 日志存放文件夹
set logPath=%mainPath%log\
rem 日志存放路径
set Log=%logPath%%date:~0,4%-%date:~5,2%-%date:~8,2%.log

rem 源列表存放路径
set temPath=%mainPath%tmp\
rem 更新文件存放路径
set updateSavePath=%mainPath%history\%date:~0,4%-%date:~5,2%-%date:~8,2%\
rem 更新列表存放路径
set currentUpdate=%updateSavePath%update.list
rem 更新列表临时存放
set tempSourceList=%temPath%update.list
rem 上一次更新源文件
set lastUpdate=%temPath%last.update

rem 驱动文件夹
set DriveLibraryPath=%mainPath%drive\
rem 下载驱动
set transferDrive=%DriveLibraryPath%transfer\FTP.bat
rem 验证驱动
set validationDrive=%DriveLibraryPath%validation\hash.bat
set signatureCheckDrive=%DriveLibraryPath%validation\signature.bat
rem 安装驱动
set installDrive=%DriveLibraryPath%install\install.bat

rem 其他参数
REM 全局任务状态标识符
SET isSuccess=1
set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%

SET updateTotalLength=0


echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 开始进行系统安全更新流程 >> %Log%
rem 默认IP值
set LocalIP=169.254.254.254
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% 默认IP值为 %LocalIP% >> %Log%
rem 随机错峰时间
set /a StaggerTime=%RANDOM%%%300
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% 默认错峰时间为 %StaggerTime% >> %Log%

rem 载入配置文件
:LoadConfig
for /f "tokens=1-2 delims==" %%i in (%commonConfig%) do (
    ECHO %%i | findstr # && set comment=1 || echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 载入 %%i 参数 >> %Log%
    if '%%j' neq '' set %%i=%%j
)
if not defined Address (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 配置文件无效 >> %Log%
    SET isSuccess=0
    GOTO :Fail
)


:PreInitial
md %updateSavePath% >nul 2>nul
del /f /q %tempSourceList% >nul 2>nul

::获取IP地址
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
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% IP值更新为: %LocalIP% >> %Log%

:UpdateStaggerTime
setlocal enabledelayedexpansion
for /f "tokens=4 delims=." %%a in ("%LocalIP%") do (
    SET id=%%a
    set /a StaggerTime=%Deadline%*3600/255
    set /a StaggerTime=!StaggerTime!*!id!
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %COMPUTERNAME% 错峰时间更新为 !StaggerTime! >> %Log%
::结束初始化 准备进行同步阶段
:EndInitial
if /i '%Protocol%' EQU 'FTP' (
    goto :FTPTransfer
) else (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 该协议暂不受支持，请更换其他支持的协议。 >> %Log%
    goto :EOF
)

::文件传输阶段
:FTPTransfer
setlocal enabledelayedexpansion
call %transferDrive% %SourceList% download %temPath%
if %errorlevel% NEQ 0 (
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 更新源下载失败，请检查环境后重试！ >> %Log%
	goto :Fail
)
copy /b /y %tempSourceList% %currentUpdate%

rem 获取更新文件hash
call %validationDrive% %currentUpdate% > %TEMP%\newHash
call %validationDrive% %lastUpdate% > %TEMP%\oldHash
set /p currentUpdateHash=<%TEMP%\newHash
set /p lastUpdateHash=<%TEMP%\oldHash

echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 当前源 Hash： !currentUpdateHash! 上次源 Hash:  !lastUpdateHash! >> %Log%

rem 判断是否与上次更新相符
if '%currentUpdateHash%' NEQ '%lastUpdateHash%' (
    if '%currentUpdateHash%' EQU 'null' (
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 源更新下载失败，不予更新。 >> %Log%
        SET isSuccess=0
        goto :Fail
    ) else (
        ::输出错峰时间日志
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 本机错峰下载等待时间: !StaggerTime! 秒 >>  %Log%
        set StaggerTime=15
        ping -n !StaggerTime! 127.1 > nul
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 本机错峰下载等待完成，进行更新下载 >>  %Log%
        for /f "tokens=1-3 delims= " %%i in (%currentUpdate%) do (
            call %transferDrive% %%i download %updateSavePath%
            if %errorlevel% EQU 0 set /a updateTotalLength+=%%k
        )
    )
) else (
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 本次更新与上次更新一致，不予更新。 >> %Log%
    goto :Clean
)
rem 写入日志
set /a humanSize=%updateTotalLength%/1024/1024
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 本次更新文件总量为：%humanSize%M >>  %Log%
GOTO :Validation

:Validation
cd /d %updateSavePath%
setlocal enabledelayedexpansion
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 进入更新文件校验流程,当前工作目录: %CD% >>  %Log%
for /f "tokens=1 delims= " %%i in (%currentUpdate%) do (
    ::获取文件名
    set fileName=%%~xni
    set fileFullPath=%updateSavePath%%%~xni
    ::获取文件hash值
    call %validationDrive% !fileFullPath! > %TEMP%\hash_result
    set /p fileHash=< %TEMP%\hash_result
    ::获取文件长度
    FOR /F 'usebackq' %%q IN ( '!fileFullPath!' ) DO set fileSize=%%~zq

    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 文件名:!fileName! Hash: !fileHash! Size: !fileSize! >> %Log%
    findstr /i !fileSize! %currentUpdate% > NUL && set sizeOK=1
    findstr /i !fileHash! %currentUpdate% > NUL && set hashOK=1
    if DEFINED sizeOK (
		IF DEFINED hashOK (
			echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 更新文件 !fileName! 与服务器文件一致。 >> %Log%
      	) else (
      		SET isSuccess=0
      		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 网络传输出错致 !fileName! Hash校验未通过。 >> %Log%
      	)
    ) else (
    	SET isSuccess=0
        echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 更新文件 !fileName! 下载不完整。 >> %Log%
    )
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 更新文件校验完毕，准备进行安装更新 >>  %Log%
goto :Install


:Install
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 进入更新文件安装流程,当前工作目录: %CD% >>  %Log%
for /f "tokens=1 delims= " %%a in (%currentUpdate%) do (
	set updateName=%%~xna
	SET updateFullPath=%updateSavePath%%%~xna
	IF %CheckDigitalSignature% EQU 1 (
		ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time 依据用户配置检查更新文件数字签名情况 >> %Log%
		CALL %signatureCheckDrive% !updateFullPath!
		IF !errorlevel! NEQ 0 (
            ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time 更新文件%updateName%数字签名不正常 >> %Log%
			SET signcheckerror=1
			SET isSuccess=0
		)
	)
	IF NOT DEFINED signcheckerror (
		ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time 准备安装 !updateName! 更新,请稍后 >> %Log%
		call %installDrive% !updateFullPath!
		IF !errorlevel! NEQ 0 SET isSuccess=0
	)
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time 更新 !updateName! 安装流程完成. >> %Log%
)
echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 所有更新文件安装流程已完成! >>  %Log%
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
    echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 准备上传操作日志。 >> %Log%
	IF '%LogReport%' EQU '1' (
		if '%isSuccess%' EQU '1' (
			REM 日志上传预处理
			call %transferDrive% %Log% upload Log\%date:~0,4%-%date:~5,2%-%date:~8,2%\%LocalIP%.log
		) ELSE (
			call %transferDrive% %Log% upload Log\%date:~0,4%-%date:~5,2%-%date:~8,2%\%LocalIP%-Fail.log
		)
	)
) ELSE (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 用户设置无须上传日志。 >>  %Log%
)

:Clean
del /q %TEMP%newHash
del /q %TEMP%oldHash
del /q %TEMP%\hash_result
del /q %tempSourceList%


