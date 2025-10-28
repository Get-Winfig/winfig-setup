<#
============================================================
Windows 11 Debloat Script
Author : Armoghan-ul-Mohmin
Date   : 2025-10-26
Purpose: Clean, transparent, and interactive bloatware remover
============================================================
#>

#  Set UTF-8 with BOM Encoding for Output
$utf0withBom = New-Object System.Text.UTF8Encoding $true
$OutputEncoding = [System.Text.UTF8Encoding]::new($true)
[Console]::OutputEncoding = $utf0withBom

# Create log file
$LogFile = "C:\Winfig-Logs\Debloat.log"
if (Test-Path $LogFile) { Remove-Item $LogFile -Force }
New-Item -ItemType File -Path $LogFile -Force | Out-Null

# Function: Write to console + log
function Log-Output {
    param (
        [string]$Message,
        [ConsoleColor]$Color = "Gray",
        [switch]$NoNewLine
    )
    Write-Host $Message -ForegroundColor $Color -NoNewline:$NoNewLine
    Add-Content -Path $LogFile -Value ($Message -replace "`e\[[0-9;]*m", "")
}

# ============================================
# Package List
# ============================================
$Packages = @(
    @{
        Name = "3D Viewer"
        ID = "Microsoft.Microsoft3DViewer"
        Description = "Legacy 3D model viewer. Unnecessary for most users."
    },
    @{
        Name = "Bing Search"
        ID = "Microsoft.BingSearch"
        Description = "Search integration tied to Bing - redundant and telemetry-heavy."
    },
    @{
        Name = "Clipchamp"
        ID = "Clipchamp.Clipchamp"
        Description = "Microsoft video editor app (ad-heavy)."
    },
    @{
        Name = "Cortana"
        ID = "Microsoft.549981C3F5F10"
        Description = "Deprecated personal assistant, replaced by Copilot."
    },
    @{
        Name = "Dev Home"
        ID = "Microsoft.Windows.DevHome"
        Description = "Developer dashboard app introduced in Windows 11."
    },
    @{
        Name = "Microsoft Family"
        ID = "MicrosoftCorporationII.MicrosoftFamily"
        Description = "Parental control and family management app."
    },
    @{
        Name = "Feedback Hub"
        ID = "Microsoft.WindowsFeedbackHub"
        Description = "Telemetry feedback tool - safe to remove."
    },
    @{
        Name = "Edge Game Assist"
        ID = "Microsoft.Edge.GameAssist"
        Description = "Game overlay integration for Microsoft Edge."
    },
    @{
        Name = "Get Help"
        ID = "Microsoft.GetHelp"
        Description = "Microsoft support app; use web browser instead."
    },
    @{
        Name = "Mixed Reality Portal"
        ID = "Microsoft.MixedReality.Portal"
        Description = "For VR headsets - not required unless using HoloLens."
    },
    @{
        Name = "Mail and Calendar"
        ID = "microsoft.windowscommunicationsapps"
        Description = "Outlook-based mail and calendar app."
    },
    @{
        Name = "Weather"
        ID = "Microsoft.BingWeather"
        Description = "Microsoft weather app."
    },
    @{
        Name = "Xbox Game Bar"
        ID = "Microsoft.XboxGameBar"
        Description = "Game overlay with telemetry - safe to remove."
    },
    @{
        Name = "Wallet"
        ID = "Microsoft.Wallet"
        Description = "Old digital wallet app - obsolete."
    }
)

# ============================================
# Initialize Counters
# ============================================
$Total   = $Packages.Count
$Count   = 0
$Removed = 0
$Skipped = 0
$Failed  = 0

# ============================================
# Main Loop with Progress Bar
# ============================================
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "        Starting Winfig Windows Debloat Tool " -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

foreach ($pkg in $Packages) {
    $Count++
    $percent = [math]::Round(($Count / $Total) * 100, 0)

    Write-Progress -Activity "Removing Bloatware..." -Status "[$Count / $Total] Processing $($pkg.Name)" -PercentComplete $percent

    Log-Output "------------------------------------------------------------"
    Log-Output "[>] Processing: $($pkg.Name) - $($pkg.Description)" -Color Cyan

    $found = Get-AppxPackage -Name $pkg.ID -AllUsers -ErrorAction SilentlyContinue

    if ($found) {
        try {
            Remove-AppxPackage -Package $found.PackageFullName -AllUsers -ErrorAction Stop
            Log-Output "   [OK] Successfully removed: $($pkg.Name)" -Color Green
            $Removed++
        } catch {
            Log-Output "   [x] Failed to remove: $($pkg.Name) - $_" -Color Red
            $Failed++
        }
    } else {
        Log-Output "   [!] Not found: $($pkg.Name) - skipping." -Color Yellow
        $Skipped++
    }

    Start-Sleep -Milliseconds 300
}

# ============================================
# Summary
# ============================================
Write-Progress -Activity "Winfig Debloat Complete" -Completed
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Debloat Summary:" -ForegroundColor Yellow
Write-Host "------------------------------------------------------------"
Write-Host ("[OK] Removed  : {0}" -f $Removed) -ForegroundColor Green
Write-Host ("[!] Skipped   : {0}" -f $Skipped) -ForegroundColor Yellow
Write-Host ("[x] Failed    : {0}" -f $Failed) -ForegroundColor Red
Write-Host "------------------------------------------------------------"
Write-Host " Log saved at : $LogFile" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Debloat process finished successfully!" -ForegroundColor Green
