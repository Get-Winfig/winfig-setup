@echo off
setlocal enabledelayedexpansion
title Winfig Unattend.xml Setup Utility
cls

REM ============================================
REM ANSI color setup
REM ============================================
for /f "delims=" %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"
set "COLOR_INFO=%ESC%[96m"
set "COLOR_OK=%ESC%[92m"
set "COLOR_WARN=%ESC%[93m"
set "COLOR_ERR=%ESC%[91m"
set "COLOR_TITLE=%ESC%[95m"
set "COLOR_RESET=%ESC%[0m"

echo %COLOR_TITLE%============================================================%COLOR_RESET%
echo %COLOR_TITLE%              Winfig Unattend.xml Setup Tool%COLOR_RESET%
echo %COLOR_TITLE%============================================================%COLOR_RESET%
echo.

REM ============================================
REM Step 1: Download Unattend.xml
REM ============================================

echo %COLOR_INFO%[i] Downloading unattend.xml template...%COLOR_RESET%
curl -L https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.xml -o unattend.xml >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[x] Failed to download unattend.xml%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[+] Successfully downloaded unattend.xml%COLOR_RESET%
echo.

REM ============================================
REM Step 2: Backup
REM ============================================

echo %COLOR_INFO%[i] Creating backup of unattend.xml...%COLOR_RESET%
copy unattend.xml unattend.xml.bak >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[x] Failed to create backup of unattend.xml%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[+] Backup created: unattend.xml.bak%COLOR_RESET%
echo.

REM ============================================
REM Step 3: User Input (ask then replace each)
REM ============================================

echo %COLOR_INFO%[i] Please enter configuration details below.%COLOR_RESET%
echo.

:: USERNAME
set /p USERNAME="Enter username: "
if "%USERNAME%"=="" (
    echo %COLOR_WARN%[!] No username entered. Aborting.%COLOR_RESET%
    exit /b 1
)

:: DISPLAY NAME
set /p DISPLAY="Enter Display name: "
if "!DISPLAY!"=="" (
    echo %COLOR_WARN%[!] No display name entered. Aborting.%COLOR_RESET%
    exit /b 1
)

:: GROUP
echo Select User group:
echo   1. Administrators
echo   2. Users
set /p GROUP="Enter User group (1/2): "
if "%GROUP%"=="1" (
    set "GROUP=Administrators"
) else if "%GROUP%"=="2" (
    set "GROUP=Users"
) else (
    echo %COLOR_WARN%[!] Invalid selection. Defaulting to 'Users'.%COLOR_RESET%
    set "GROUP=Users"
)

REM Save inputs to JSON file
echo %COLOR_INFO%[i] Saving configuration to JSON file...%COLOR_RESET%
echo { > config.json
echo   "username": "!USERNAME!", >> config.json
echo   "displayname": "!DISPLAY!", >> config.json
echo   "group": "!GROUP!" >> config.json
echo } >> config.json

REM Use PowerShell to read JSON and replace all values at once
echo %COLOR_INFO%[i] Processing replacements...%COLOR_RESET%
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$config = Get-Content 'config.json' | ConvertFrom-Json; " ^
    "$content = Get-Content 'unattend.xml' -Raw; " ^
    "$content = $content -replace 'DummyUser', $config.username; " ^
    "$content = $content -replace 'DummyComputer', $config.displayname; " ^
    "$content = $content -replace 'UserSelection', $config.group; " ^
    "Set-Content 'unattend.xml' $content -Encoding UTF8"

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[x] Replacement processing failed.%COLOR_RESET%
    exit /b 1
)

REM Clean up JSON file
if exist config.json del config.json

echo %COLOR_OK%[+] All replacements completed successfully.%COLOR_RESET%
echo.

REM ============================================
REM Step 4: Verify
REM ============================================

echo %COLOR_INFO%[i] Verifying changes in unattend.xml...%COLOR_RESET%
echo %COLOR_INFO%[i] Values entered:%COLOR_RESET%
echo %COLOR_OK%    Username: %COLOR_RESET%!USERNAME!
echo %COLOR_OK%    Display : %COLOR_RESET%!DISPLAY!
echo %COLOR_OK%    Group   : %COLOR_RESET%!GROUP!
echo.

findstr /C:"!USERNAME!" unattend.xml >nul || (echo %COLOR_ERR%[x] Username not found.%COLOR_RESET% & exit /b 1)
findstr /C:"!DISPLAY!" unattend.xml >nul || (echo %COLOR_ERR%[x] Display name not found.%COLOR_RESET% & exit /b 1)
findstr /C:"!GROUP!" unattend.xml >nul || (echo %COLOR_ERR%[x] Group not found.%COLOR_RESET% & exit /b 1)
echo %COLOR_OK%[+] Verification passed — all values correctly replaced%COLOR_RESET%
echo.

REM ============================================
REM Step 5: Copy to Panther
REM ============================================

echo %COLOR_INFO%[i] Copying unattend.xml to C:\Windows\Panther...%COLOR_RESET%
if not exist C:\Windows\Panther mkdir C:\Windows\Panther
copy unattend.xml C:\Windows\Panther >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[x] Failed to copy unattend.xml to C:\Windows\Panther%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[+] unattend.xml copied successfully%COLOR_RESET%
echo.


REM ============================================
REM Step 6: Sysprep
REM ============================================

echo %COLOR_TITLE%============================================================%COLOR_RESET%
echo %COLOR_WARN%[!] WARNING: System will reboot in 5 seconds after applying unattend.xml%COLOR_RESET%
echo %COLOR_INFO%    Press Ctrl+C now to cancel this operation.%COLOR_RESET%
echo %COLOR_TITLE%============================================================%COLOR_RESET%
timeout /t 5 /nobreak >nul
echo %COLOR_INFO%[i] Running Sysprep... please wait.%COLOR_RESET%
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
exit /b 0
