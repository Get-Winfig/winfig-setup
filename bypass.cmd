@echo off
setlocal enabledelayedexpansion
title Winfig - Windows Unattend.xml Setup Utility
mode con: cols=80 lines=45
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
set "COLOR_ACCENT=%ESC%[94m"
set "COLOR_DIM=%ESC%[90m"
set "COLOR_RESET=%ESC%[0m"

REM ============================================
REM Header
REM ============================================
echo.
echo %COLOR_TITLE%===============================================================%COLOR_RESET%
echo %COLOR_TITLE%           Windows Deployment Automation Tool                 %COLOR_RESET%
echo %COLOR_TITLE%===============================================================%COLOR_RESET%
echo.

REM ============================================
REM Step 0: Template Selection
REM ============================================
echo %COLOR_INFO%[ STEP 1 OF 7 ] SELECT DEPLOYMENT TEMPLATE%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo.
echo %COLOR_ACCENT%    Standard Templates%COLOR_RESET%
echo.
echo     1.  Local Account Only
echo     2.  Local Account + Debloat
echo     3.  Microsoft Account + Debloat
echo.
echo %COLOR_ACCENT%    Virtualization Templates%COLOR_RESET%
echo.
echo     4.  VMware Basic
echo     5.  VMware + Debloat
echo     6.  VirtualBox Basic
echo     7.  VirtualBox + Debloat
echo.
echo %COLOR_ACCENT%    Actions%COLOR_RESET%
echo.
echo     0.  Cancel Setup
echo.
echo %COLOR_DIM%----------------------------------------------------------------%COLOR_RESET%

:RETRY_SELECT
set /p TEMP="%COLOR_INFO%[SELECT] Enter choice (0-7): %COLOR_RESET%"

if "%TEMP%"=="1" (
    set "TEMPLATE_NAME=Local Account Only"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.local.xml"
) else if "%TEMP%"=="2" (
    set "TEMPLATE_NAME=Local Account + Debloat"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.xml"
) else if "%TEMP%"=="3" (
    set "TEMPLATE_NAME=Microsoft Account + Debloat"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.online.xml"
) else if "%TEMP%"=="4" (
    set "TEMPLATE_NAME=VMware Basic"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.vmware.xml"
) else if "%TEMP%"=="5" (
    set "TEMPLATE_NAME=VMware + Debloat"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.vmware-debloat.xml"
) else if "%TEMP%"=="6" (
    set "TEMPLATE_NAME=VirtualBox Basic"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.virtualbox.xml"
) else if "%TEMP%"=="7" (
    set "TEMPLATE_NAME=VirtualBox + Debloat"
    set "UNATTEND_URL=https://raw.githubusercontent.com/Get-Winfig/winfig-setup/main/unattend.virtualbox-debloat.xml"
) else if "%TEMP%"=="0" (
    echo.
    echo %COLOR_WARN%[NOTICE] Setup cancelled by user%COLOR_RESET%
    exit /b 0
) else (
    echo %COLOR_ERR%[ERROR] Invalid selection. Please choose 0-7%COLOR_RESET%
    goto RETRY_SELECT
)

echo.
echo %COLOR_OK%[SUCCESS] Template selected: %TEMPLATE_NAME%%COLOR_RESET%
echo.

REM ============================================
REM Step 1: Download Template
REM ============================================
echo %COLOR_INFO%[ STEP 2 OF 7 ] DOWNLOADING TEMPLATE%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo %COLOR_INFO%[INFO] Downloading unattend.xml template...%COLOR_RESET%
curl -L %UNATTEND_URL% -o unattend.xml >nul 2>&1

if not exist unattend.xml (
    echo %COLOR_ERR%[ERROR] Failed to download template from:%COLOR_RESET%
    echo %COLOR_ERR%        %UNATTEND_URL%%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[SUCCESS] Template downloaded successfully%COLOR_RESET%
echo.

REM ============================================
REM Step 2: Create Backup
REM ============================================
echo %COLOR_INFO%[ STEP 3 OF 7 ] CREATING BACKUP%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
copy unattend.xml unattend.xml.bak >nul 2>&1
echo %COLOR_OK%[SUCCESS] Backup created: unattend.xml.bak%COLOR_RESET%
echo.

REM ============================================
REM Step 3: User Configuration
REM ============================================
if "%TEMP%" == "3" goto :SKIP_USER_INPUT

echo %COLOR_INFO%[ STEP 4 OF 7 ] USER CONFIGURATION%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo %COLOR_INFO%[INFO] Please enter user account details:%COLOR_RESET%
echo.

:GET_USERNAME
set /p USERNAME="%COLOR_INFO%[INPUT] Username: %COLOR_RESET%"
if "%USERNAME%"=="" (
    echo %COLOR_ERR%[ERROR] Username is required%COLOR_RESET%
    goto GET_USERNAME
)

:GET_DISPLAY
set /p DISPLAY="%COLOR_INFO%[INPUT] Display Name: %COLOR_RESET%"
if "!DISPLAY!"=="" (
    echo %COLOR_ERR%[ERROR] Display name is required%COLOR_RESET%
    goto GET_DISPLAY
)

echo.
echo %COLOR_INFO%[INFO] Select user privilege level:%COLOR_RESET%
echo.
echo     [1] Administrators - Full system access
echo     [2] Users - Standard user privileges
echo.

:GET_GROUP
set /p GROUP="%COLOR_INFO%[INPUT] Privilege level (1-2): %COLOR_RESET%"
if "%GROUP%"=="1" (
    set "GROUP=Administrators"
) else if "%GROUP%"=="2" (
    set "GROUP=Users"
) else (
    echo %COLOR_ERR%[ERROR] Invalid choice%COLOR_RESET%
    goto GET_GROUP
)

echo.
echo %COLOR_INFO%[INFO] Configuration Summary:%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo %COLOR_DIM%^%COLOR_RESET% Username:     !USERNAME!%COLOR_DIM%                         ^%COLOR_RESET%
echo %COLOR_DIM%^%COLOR_RESET% Display Name: !DISPLAY!%COLOR_DIM%                         ^%COLOR_RESET%
echo %COLOR_DIM%^%COLOR_RESET% Privileges:   !GROUP!%COLOR_DIM%                         ^%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo.

echo %COLOR_INFO%[INFO] Applying configuration to template...%COLOR_RESET%
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$content = Get-Content 'unattend.xml' -Raw; " ^
    "$content = $content -replace 'DummyUser', '!USERNAME!'; " ^
    "$content = $content -replace 'DummyComputer', '!DISPLAY!'; " ^
    "$content = $content -replace 'UserSelection', '!GROUP!'; " ^
    "Set-Content 'unattend.xml' $content -Encoding UTF8"

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[ERROR] Failed to update template%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[SUCCESS] Configuration applied successfully%COLOR_RESET%
echo.

REM ============================================
REM Step 4: Verification
REM ============================================
echo %COLOR_INFO%[ STEP 5 OF 7 ] VERIFICATION%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo %COLOR_INFO%[INFO] Verifying template configuration...%COLOR_RESET%

set "VERIFY_FAIL=0"
findstr /C:"!USERNAME!" unattend.xml >nul || set "VERIFY_FAIL=1"
findstr /C:"!DISPLAY!" unattend.xml >nul || set "VERIFY_FAIL=1"
findstr /C:"!GROUP!" unattend.xml >nul || set "VERIFY_FAIL=1"

if !VERIFY_FAIL! EQU 1 (
    echo %COLOR_ERR%[ERROR] Verification failed - configuration not applied%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[SUCCESS] All verifications passed%COLOR_RESET%
echo.

REM ============================================
REM Step 5: File Review
REM ============================================
:SKIP_USER_INPUT
echo %COLOR_INFO%[ STEP 6 OF 7 ] FILE REVIEW%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
set /p REVIEW="%COLOR_INFO%[INPUT] Review configuration in Notepad? (y/N): %COLOR_RESET%"
if /I "%REVIEW%"=="Y" (
    echo %COLOR_INFO%[INFO] Opening unattend.xml for review...%COLOR_RESET%
    start /wait notepad.exe unattend.xml
    echo %COLOR_OK%[SUCCESS] Review completed%COLOR_RESET%
)
echo.

REM ============================================
REM Step 6: Deploy to Panther
REM ============================================
echo %COLOR_INFO%[ STEP 7 OF 7 ] DEPLOYMENT%COLOR_RESET%
echo %COLOR_DIM%+----------------------------------------------------------------+%COLOR_RESET%
echo %COLOR_INFO%[INFO] Deploying configuration to system...%COLOR_RESET%

if not exist C:\Windows\Panther mkdir C:\Windows\Panther
copy unattend.xml C:\Windows\Panther >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo %COLOR_ERR%[ERROR] Failed to deploy to C:\Windows\Panther%COLOR_RESET%
    exit /b 1
)
echo %COLOR_OK%[SUCCESS] Configuration deployed successfully%COLOR_RESET%
echo.

REM ============================================
REM Final: Sysprep Confirmation
REM ============================================
echo %COLOR_WARN%===============================================================%COLOR_RESET%
echo %COLOR_WARN%                    SYSTEM PREPARATION                         %COLOR_RESET%
echo %COLOR_WARN%===============================================================%COLOR_RESET%
echo.
echo %COLOR_WARN%[WARNING] The following actions will be performed:%COLOR_RESET%
echo.
echo %COLOR_WARN%    - Sysprep will generalize this Windows installation%COLOR_RESET%
echo %COLOR_WARN%    - System will reboot automatically%COLOR_RESET%
echo %COLOR_WARN%    - Windows OOBE will start with your configuration%COLOR_RESET%
echo %COLOR_WARN%    - All user data and applications will be preserved%COLOR_RESET%
echo.
echo %COLOR_ERR%[CRITICAL] Ensure all work is saved before continuing!%COLOR_RESET%
echo.
echo %COLOR_DIM%----------------------------------------------------------------%COLOR_RESET%

set /p SYSPREP="%COLOR_WARN%[CONFIRM] Proceed with Sysprep and reboot? (y/N): %COLOR_RESET%"
if /I "%SYSPREP%"=="Y" (
    echo.
    echo %COLOR_INFO%[INFO] Starting Sysprep process...%COLOR_RESET%
    echo %COLOR_DIM%[INFO] System will reboot in 5 seconds...%COLOR_RESET%
    timeout /t 5 /nobreak >nul
    %WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
) else (
    echo.
    echo %COLOR_OK%[SUCCESS] Setup completed successfully!%COLOR_RESET%
    echo.
    echo %COLOR_INFO%[INFO] Manual deployment command:%COLOR_RESET%
    echo %COLOR_DIM%    sysprep /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot%COLOR_RESET%
    echo.
    echo %COLOR_INFO%[INFO] Press any key to exit...%COLOR_RESET%
    pause >nul
)

exit /b 0
