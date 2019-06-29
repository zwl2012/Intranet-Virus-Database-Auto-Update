@echo off
set updateList=%~dp0Update\update.list
set hash=%~dp0hash.bat
set updateFolder=%~dp0update

set hh=%time:~1,2%
set mm=%time:~3,2%
set ss=%time:~6,2%
set "hh=%hh::=%"
if %hh% LSS 10 set hh=0%hh%

set "currentTime=%hh%%mm%%ss%"
set "currentTime=%currentTime: =0%"

set currentDate=%date:~0,4%%date:~5,2%%date:~8,2%
set buildTime=%currentDate%%currentTime%

chcp 936  >nul 2>nul

cd /d %updateFolder%
md %buildTime%
move * %buildTime% >nul 2>nul
cd %buildTime%


del /q %updateList% >nul 2>nul

set fileIndex=0

setlocal enabledelayedexpansion
for /f %%i in ('dir /s /b /o:n *.gz *.exe *.vdb *.msu') do (
    set /a fileIndex+=1
    set file=%%i

    ::处理文件名
    set fileName=!file:%updateFolder%=!

    ::获取文件hash值
    call %hash% !file! > %TEMP%\hash_result
    set /p fileHash=< %TEMP%\hash_result

    ::获取文件长度
    set fileSize=%%~zi

    echo !fileName! !fileHash! !fileSize!
) >> %~dp0update\update.list
copy %updateList% .\  >nul 2>nul

if %fileIndex% EQU 0 (
    echo Update文件夹内无有效文件，请检查路径及操作步骤是否正确
    cd /d %updateFolder% >nul 2>nul
    rd /s /q %buildTime% >nul 2>nul
    pause
    exit /b 1
)

del %TEMP%\hash_result

exit
