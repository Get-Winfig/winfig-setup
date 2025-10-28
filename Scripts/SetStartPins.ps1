<#
    ============================================
    Winfig Start Menu Pin Cleaner
    Author : Armoghan-ul-Mohmin
    Date   : 2025-10-26
    Purpose: Clears all default pinned Start Menu items on Windows 11
    ============================================
#>

# Set UTF-8 with BOM Encoding for Output
$utf8withBom = New-Object System.Text.UTF8Encoding $true
$OutputEncoding = [System.Text.UTF8Encoding]::new($true)
[Console]::OutputEncoding = $utf8withBom

# Create log directory
$LogDir = "C:\Winfig-Logs"
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}
$LogFile = "$LogDir\ClearStartPins.log"

# Function to log output to console and file
function Log-Output {
    param (
        [string]$Message,
        [ConsoleColor]$Color = "Gray"
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $Message
}

# Start process
Log-Output "============================================================" Cyan
Log-Output "     Starting Winfig Start Menu Pin Cleaner" Yellow
Log-Output "============================================================" Cyan

# Check Windows version (Windows 11 has Build >= 22000)
$Build = [System.Environment]::OSVersion.Version.Build
if ($Build -lt 22000) {
    Log-Output "[!] This script is only for Windows 11 (Build >= 22000)." Yellow
    exit
}

try {
    $json = '{"pinnedList":[]}'
    $key = 'Registry::HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'

    # Ensure registry key exists
    New-Item -Path $key -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    # Apply the clean pinned list policy
    Set-ItemProperty -LiteralPath $key -Name 'ConfigureStartPins' -Value $json -Type String

    Log-Output "[✓] Successfully cleared pinned Start Menu items." Green
}
catch {
    Log-Output "[x] Failed to apply Start Menu policy: $_" Red
}

Log-Output "============================================================" Cyan
Log-Output " Operation Complete. Log saved to: $LogFile" Yellow
Log-Output "============================================================" Cyan
