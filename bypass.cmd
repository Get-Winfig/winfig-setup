@echo off

REM ============================================
REM Winfig Windows 11 Bypass Script
REM ============================================

REM Step 1: Download
REM Download the unattend.xml file from the GitHub repository to temp location
echo Step 1: Downloading unattend.xml configuration file...
curl -L -o unattend.xml https://raw.githubusercontent.com/Get-Winfig/Winfig/main/winfig-setup/unattend.xml
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

REM Step 3: Replace values using CMD batch processing
REM Create a temporary batch file to handle the replacements
echo @echo off > replace.bat
echo setlocal EnableDelayedExpansion >> replace.bat
echo set "input=unattend.xml" >> replace.bat
echo set "output=unattend_customized.xml" >> replace.bat
echo if exist "!output!" del "!output!" >> replace.bat
echo for /f "usebackq delims=" %%%%a in ("!input!") do ( >> replace.bat
echo   set "line=%%%%a" >> replace.bat
echo   set "line=!line:DummyUser=%USERNAME%!" >> replace.bat
echo   set "line=!line:Dummy User=%DISPLAYNAME%!" >> replace.bat
echo   set "line=!line:DummyPassword123!=%PASSWORD%!" >> replace.bat
echo   set "line=!line:UserSelection=%USERGROUP%!" >> replace.bat
echo   echo(!line! >> "!output!" >> replace.bat
echo ) >> replace.bat

REM Execute the replacement batch file
call replace.bat

REM Clean up the temporary replacement script
del replace.bat 2>nul

REM Step 4: Copy to final location
REM Ensure the Panther directory exists
if not exist C:\Windows\Panther mkdir C:\Windows\Panther
echo Step 3: Copying customized configuration file to C:\Windows\Panther\
copy unattend_customized.xml C:\Windows\Panther\unattend.xml

REM Clean up temp files
del unattend.xml 2>nul
del unattend_customized.xml 2>nul

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
