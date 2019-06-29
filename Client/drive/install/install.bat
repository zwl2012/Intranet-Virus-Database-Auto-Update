::更新安装模块
::日期:2019年5月15日
::@ECHO OFF
TITLE 启动更新安装流程

if not defined Log (
	set Log=%~dp0debug-%date:~0,4%-%date:~5,2%-%date:~8,2%.log
)

::Mcafee补丁包
set exeArg=-silent -logfile
::微软安装包
set msuArg=/quiet /norestart /verbose

set installFile=%~f1
set installFileName=%~nx1
REM 文件全名为: %~xn1, 文件名为： %~n1, 扩展名为： %~x1
set installFileType=%~x1
set exeInstall=0
set msuInstall=0
set installFlag=0
set installType=病毒库更新

SET installLog=%TEMP%installLog

setlocal enabledelayedexpansion

echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 进入更新包安装流程。 >> %Log%
if "%installFileType%"==".exe" ( set exeInstall=1 )
if "%installFileType%"==".msu" ( set msuInstall=1 )

if %exeInstall% EQU 1 (
	%installFile% %exeArg% %installLog%
	if '!errorlevel!' neq '0'  set installFlag=!errorlevel!
) else (
	if %msuInstall% EQU 1 (
		set installType=系统更新
		%installFile% %msuArg% >> %Log%
		if '!errorlevel!' neq '0'  set installFlag=!errorlevel!
	)
)
::导入日志
for /f "eol= tokens=5 delims=	" %%i in (%installLog%) do (
	ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %%i >> %Log%
)
DEL /f /q %installLog%
if %installFlag% EQU 0 (
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType% : %installFileName% 组件已安装成功。 >> %Log%
	exit /b %installFlag%
) else (
	if %installFlag% == 43 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% 安装失败，当前计算机未找到符合条件的Mcafee产品。 >> %Log%
		exit /b 1
	)
	if %installFlag% == 2359302 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% 计算机已安装当前更新。 >> %Log%
		exit /b 0
	)
	if %installFlag% == -2145124329 (
		echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% 当前%installType%:%installFileName% 更新无法安装至当前计算机。 >> %Log%
		exit /b 1
	)
	echo %date:~0,4%-%date:~5,2%-%date:~8,2% %time% %installType%:%installFileName% 计算机未能成功安装当前更新。 >> %Log%
	exit /b 1
)
