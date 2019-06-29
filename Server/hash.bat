@echo off
if not defined Log (
	set currentPath=%~dp0
	set currentTime=%date:~0,4%-%date:~5,2%-%date:~8,2% %time%
	set currentDate=%date:~0,4%-%date:~5,2%-%date:~8,2%
	set Log=%~dp0%date:~0,4%-%date:~5,2%-%date:~8,2%.log
)

::哈希默认值
set hashVal=null

echo %currentTime% 开始进行文件哈希值校验流程。 >> %Log%

setlocal enabledelayedexpansion
::路径处理
set source=%~xf1

::参数检测
if '%~1' == '' set err=1
if '%~1' == ' ' set err=1
if not exist %source%  set err=2
if defined err (
	if !err! equ 2 (
		echo %currentTime% %~n0 待计算文件路径不存在,退出Hash流程 >> %Log%
	) else (
		echo %currentTime% %~n0 输入参数不合法,退出计算Hash流程 >> %Log%
	)
    exit /b -1
)

::旧系统兼容(默认系统路径)
set certutil=%windir%\certutil.exe 
set xp_path=%certutil%
set win7path=%windir%\System32\certutil.exe

if not exist %xp_path% if not exist %win7path% (
   set certutil=%~dp0certutil\certutil.exe 
) else (
   set certutil=%win7path%
)

rem 因兼容考虑 故禁用其他的hash方式
rem set methodList='MD5 SHA1 SHA256'
rem echo %methodList% | findstr %2 &&  set hashType=%2 || set hashType=SHA1

:: 临时文件
set hashTEMP=%TMP%\%currentDate%-hash.info

%certutil% -hashfile %source% > %hashTEMP%
for /f "tokens=* delims=" %%i in (%hashTEMP%) do (
	set /a n+=1 & if !n!==2 set "hashVal=%%i"
)

rem 为兼容win8以下系统输出 处理下哈希值输出问题
set hashVal=!hashVal: =!
echo !hashVal! | findstr 'certutil' && set error=1 || set success=1

del /f /q %hashTEMP%

if defined success (
    echo %hashVal%
    echo %currentTime% 文件 %~f1 的HASH值为:!hashVal! >> %Log%
    exit /b 0
) else (
    echo %hashVal%
    echo %currentTime% 文件 %~f1 的HASH值获取失败，文件可能损坏 >> %Log%
    exit /b 1
)

