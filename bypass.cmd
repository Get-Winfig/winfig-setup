@echo off
setlocal enabledelayedexpansion
title Winfig Unattend.xml Setup Utility
cls

echo ============================================================
echo               Winfig Unattend.xml Setup Tool
echo ============================================================
echo.

REM ============================================
REM Step 1: Download Unattend.xml template
REM ============================================

echo [i] Downloading unattend.xml template...
curl -L https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.xml -o unattend.xml >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [x] Failed to download unattend.xml
    exit /b 1
)
echo [+] Successfully downloaded unattend.xml
echo.

REM ============================================
REM Step 2: Backup original Unattend.xml
REM ============================================

echo [i] Creating backup of unattend.xml...
copy unattend.xml unattend.xml.bak >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [x] Failed to create backup of unattend.xml
    exit /b 1
)
echo [+] Backup created: unattend.xml.bak
echo.

REM ============================================
REM Step 3: Get user input
REM ============================================

echo [i] Please enter configuration details below.
echo.

set /p USERNAME="Enter username: "
set /p PASSWORD="Enter password: "
set /p DISPLAY="Enter Display name: "

echo.
echo Select User group:
echo   1. Administrators
echo   2. Users
set /p GROUP="Enter User group (1/2): "

if "%GROUP%"=="1" (
    set GROUP=Administrators
) else if "%GROUP%"=="2" (
    set GROUP=Users
) else (
    echo [!] Invalid selection. Defaulting to 'Users'.
    set GROUP=Users
)
echo [+] User group set to: !GROUP!
echo.

REM ============================================
REM Step 4: Modify Unattend.xml
REM ============================================

echo [i] Updating unattend.xml with user-provided values...
powershell -Command "(Get-Content unattend.xml) -replace 'DummyUser', '%USERNAME%' | Set-Content unattend.xml"
powershell -Command "(Get-Content unattend.xml) -replace 'DummyPassword123!', '%PASSWORD%' | Set-Content unattend.xml"
powershell -Command "(Get-Content unattend.xml) -replace 'DummyComputer', '%DISPLAY%' | Set-Content unattend.xml"
powershell -Command "(Get-Content unattend.xml) -replace 'UserSelection', '%GROUP%' | Set-Content unattend.xml"

if %ERRORLEVEL% NEQ 0 (
    echo [x] Failed to modify unattend.xml
    exit /b 1
)
echo [+] unattend.xml updated successfully
echo.

REM ============================================
REM Step 5: Verify replacements
REM ============================================

echo [i] Verifying changes in unattend.xml...
findstr /C:"%USERNAME%" unattend.xml >nul || (echo [x] Username not found. & exit /b 1)
findstr /C:"%PASSWORD%" unattend.xml >nul || (echo [x] Password not found. & exit /b 1)
findstr /C:"%DISPLAY%" unattend.xml >nul || (echo [x] Display name not found. & exit /b 1)
findstr /C:"%GROUP%" unattend.xml >nul || (echo [x] Group not found. & exit /b 1)
echo [+] Verification passed — all values correctly replaced
echo.

REM ============================================
REM Step 6: Copy to Windows setup directory
REM ============================================

echo [i] Copying unattend.xml to C:\Windows\Panther...
if not exist C:\Windows\Panther mkdir C:\Windows\Panther
copy unattend.xml C:\Windows\Panther >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [x] Failed to copy unattend.xml to C:\Windows\Panther
    exit /b 1
)
echo [+] unattend.xml copied successfully
echo.

REM ============================================
REM Step 7: Cleanup
REM ============================================

echo [i] Cleaning up temporary files...
del unattend.xml >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [!] Warning: Could not delete unattend.xml (may not exist)
) else (
    echo [+] Temporary unattend.xml removed
)
echo.

REM ============================================
REM Step 8: Run Sysprep
REM ============================================

echo ============================================================
echo [!] WARNING: System will reboot in 5 seconds after applying unattend.xml
echo     Press Ctrl+C now to cancel this operation.
echo ============================================================
timeout /t 5 /nobreak >nul
echo [i] Running Sysprep... please wait.
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
