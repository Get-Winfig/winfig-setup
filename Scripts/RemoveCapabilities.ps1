# =================================================================
#                          WINFIG CAPABILITY REMOVER
# =================================================================
# Author: Armoghan-ul-Mohmin
# Date: 2025-10-26
# Description:
#   Removes unnecessary Windows optional capabilities
#   such as Internet Explorer, WordPad, Fax, Speech, etc.
#   Safe for debloating and improving system performance.
# =================================================================

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    Write-Host "[x] Please run this script as Administrator!" -ForegroundColor Red
    exit
}

# Create log directory
$LogDir = "C:\Winfig-Logs"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Define log file
$LogFile = "$LogDir\Remove-Capabilities.log"
New-Item -ItemType File -Path $LogFile -Force | Out-Null

# Function to write both to console and log file
function Log-Output {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $Message
}

# =================================================================
#                        CAPABILITY LIST
# =================================================================
$Capabilities = @(
    @{
        Name = "Print Fax and Scan";
        ID = "Print.Fax.Scan";
        Description = "Legacy fax and scan features - safe to remove."
    },
    @{
        Name = "Handwriting Language Support";
        ID = "Language.Handwriting";
        Description = "Used for stylus input - not needed on most systems."
    },
    @{
        Name = "Internet Explorer";
        ID = "Browser.InternetExplorer";
        Description = "Legacy browser - deprecated and unsafe."
    },
    @{
        Name = "Math Recognizer";
        ID = "MathRecognizer";
        Description = "Math handwriting recognition - rarely used."
    },
    @{
        Name = "OneSync Service";
        ID = "OneCoreUAP.OneSync";
        Description = "Old mail/calendar sync service - safe to remove."
    },
    @{
        Name = "OpenSSH Client";
        ID = "OpenSSH.Client";
        Description = "Optional - remove if not used for remote shell access."
    },
    @{
        Name = "Quick Assist";
        ID = "App.Support.QuickAssist";
        Description = "Remote assistance app - safe to remove if unused."
    },
    @{
        Name = "Speech Recognition";
        ID = "Language.Speech";
        Description = "Voice input system - remove if not needed."
    },
    @{
        Name = "Text-to-Speech";
        ID = "Language.TextToSpeech";
        Description = "Removes TTS - safe to remove if accessibility not needed."
    },
    @{
        Name = "Windows Hello Face (Legacy)";
        ID = "Hello.Face.18967";
        Description = "Legacy face recognition module - obsolete."
    },
    @{
        Name = "Windows Hello Migration";
        ID = "Hello.Face.Migration.18967";
        Description = "Migration support for older Windows Hello - safe to remove."
    },
    @{
        Name = "Windows Hello Face (Modern)";
        ID = "Hello.Face.20134";
        Description = "Modern face recognition - remove if not used."
    },
    @{
        Name = "Windows Media Player";
        ID = "Media.WindowsMediaPlayer";
        Description = "Old media player - replaceable by modern apps."
    },
    @{
        Name = "WordPad";
        ID = "Microsoft.Windows.WordPad";
        Description = "Legacy text editor - deprecated in Windows 11."
    },
    @{
        Name = "Windows Recall";
        ID = "Windows.Recall";
        Description = "Windows Recall feature - rarely used."
    }
)

# =================================================================
#                        PROCESSING
# =================================================================
$total = $Capabilities.Count
$count = 0
$removed = 0
$failed = 0

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "           WINFIG CAPABILITY REMOVAL TOOL" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[i] Checking installed capabilities..." -ForegroundColor DarkCyan

$installed = Get-WindowsCapability -Online | Where-Object { $_.State -notin @('NotPresent', 'Removed') }

foreach ($cap in $Capabilities) {
    $count++
    $percent = [math]::Round(($count / $total) * 100, 0)
    Write-Progress -Activity "Removing Windows Capabilities..." -Status "Progress: $percent%" -PercentComplete $percent

    $found = $installed | Where-Object { ($_.Name -split '~')[0] -eq $cap.
    ID }

    if ($found) {
        try {
            Remove-WindowsCapability -Online -Name $found.Name -ErrorAction Stop | Out-Null
            Log-Output ("[OK] Removed  : {0}" -f $cap.Name) -Color Green
            $removed++
        } catch {
            Log-Output ("[x] Failed    : {0} - {1}" -f $cap.Name, $_.Exception.Message) -Color Red
            $failed++
        }
    } else {
        Log-Output ("[-] Skipped   : {0} (not installed)" -f $cap.Name) -Color DarkGray
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ("[✓] Process completed!  Removed: {0} | Failed: {1} | Total: {2}" -f $removed, $failed, $total) -ForegroundColor Yellow
Write-Host "[i] Log file saved at: $LogFile" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
