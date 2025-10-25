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

REM Step 3: Create PowerShell script for processing (more reliable for special characters)
echo $input = 'unattend.xml' > process.ps1
echo $output = 'edit-unattended.xml' >> process.ps1
echo $username = '%USERNAME%' >> process.ps1
echo $displayname = '%DISPLAYNAME%' >> process.ps1
echo $password = '%PASSWORD%' >> process.ps1
echo $usergroup = '%USERGROUP%' >> process.ps1
echo. >> process.ps1
echo # Read file, remove comments, and replace values >> process.ps1
echo $content = Get-Content $input -Raw >> process.ps1
echo # Remove XML comments >> process.ps1
echo $content = $content -replace '(?s)<!--.*?-->', '' >> process.ps1
echo # Replace placeholder values >> process.ps1
echo $content = $content -replace 'DummyUser', $username >> process.ps1
echo $content = $content -replace 'Dummy User', $displayname >> process.ps1
echo $content = $content -replace 'DummyPassword123!', $password >> process.ps1
echo $content = $content -replace 'UserSelection', $usergroup >> process.ps1
echo # Clean up extra whitespace from comment removal >> process.ps1
echo $content = $content -replace '(?m)^\s*$\n', '' >> process.ps1
echo Set-Content $output $content -Encoding UTF8 >> process.ps1

REM Execute PowerShell script
powershell -ExecutionPolicy Bypass -File process.ps1

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
