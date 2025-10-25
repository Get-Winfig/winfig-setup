@echo off

REM ============================================
REM Winfig Windows 11 Bypass Script
REM ============================================

REM Step 1: Download
REM Download the unattend.xml file from the GitHub repository to current directory
echo Step 1: Downloading unattend.xml configuration file...
curl -L https://raw.githubusercontent.com/Get-Winfig/winfig-setup/refs/heads/main/unattend.xml -o unattend.xml
if not exist unattend.xml (
    echo ERROR: Failed to download unattend.xml file
    pause
    exit /b 1
)

REM Step 2: Customize User Settings
echo.
echo Step 2: Customizing user account settings...
echo Please provide your custom user account details:
echo.

REM Ask for username
set /p "USERNAME=Enter your desired username (default: Admin): "
if "%USERNAME%"=="" set USERNAME=Admin

REM Ask for display name
set /p "DISPLAYNAME=Enter display name (default: %USERNAME%): "
if "%DISPLAYNAME%"=="" set DISPLAYNAME=%USERNAME%

REM Ask for password
set /p "PASSWORD=Enter your password (default: Password123!): "
if "%PASSWORD%"=="" set PASSWORD=Password123!

REM Ask for user group
echo.
echo Choose user group:
echo 1. Administrators (recommended)
echo 2. Users
echo 3. UserSelection (custom)
set /p "GROUPCHOICE=Select group (1-3, default: 1): "
if "%GROUPCHOICE%"=="" set GROUPCHOICE=1
if "%GROUPCHOICE%"=="1" set USERGROUP=Administrators
if "%GROUPCHOICE%"=="2" set USERGROUP=Users
if "%GROUPCHOICE%"=="3" set USERGROUP=UserSelection

echo.
echo Customizing unattend.xml with your settings...

REM Step 3: Replace values using inline CMD processing
setlocal EnableDelayedExpansion
set "input=unattend.xml"
set "output=edit-unattended.xml"

REM Clear output file if it exists
if exist "!output!" echo. > "!output!"

REM Process each line and perform replacements
for /f "usebackq delims=" %%a in ("!input!") do (
    set "line=%%a"
    set "line=!line:DummyUser=%USERNAME%!"
    set "line=!line:Dummy User=%DISPLAYNAME%!"
    call :ReplacePassword "!line!" "!output!"
    set "line=!RESULT!"
    set "line=!line:UserSelection=%USERGROUP%!"
    echo(!line! >> "!output!"
)
goto :ContinueScript

:ReplacePassword
setlocal DisableDelayedExpansion
set "line=%~1"
set "line=%line:DummyPassword123!=%PASSWORD%"
endlocal & set "RESULT=%line%"
goto :eof

:ContinueScript

REM Step 4: Copy to final location
REM Ensure the Panther directory exists
if not exist C:\Windows\Panther mkdir C:\Windows\Panther
echo Step 3: Copying customized configuration file to C:\Windows\Panther\
copy edit-unattended.xml C:\Windows\Panther\unattend.xml

echo Step 3a: Customized file saved as 'edit-unattended.xml' in current directory
echo Step 3b: File copied and renamed to 'C:\Windows\Panther\unattend.xml'

REM Step 5: Prepare
REM Prepare the system using Sysprep with the unattend configuration
echo Step 4: Preparing system with bypass configuration...

REM Step 6: Reboot
REM Execute Sysprep and automatically reboot the system
echo Step 5: Rebooting system to apply changes...
echo.
echo WARNING: The system will reboot in 5 seconds!
echo Press Ctrl+C to cancel...
timeout /t 5 /nobreak >nul
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
