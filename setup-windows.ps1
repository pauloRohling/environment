#Requires -RunAsAdministrator

# Remove the restrictions on PowerShell execution
Set-ExecutionPolicy Unrestricted

# Check if the license is activated
function Get-IsActivated
{
    $License = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $_.PartialProductKey }
    return $License.LicenseStatus -eq 1
}

# Set the system preferences
function Set-Preferences
{
    $ADVANCED_PATH = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $COLORS_PATH = "HKCU:\Control Panel\Colors"
    $DESKTOP_PATH = "HKCU:\Control Panel\Desktop"
    $GAMEDVR_PATH = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
    $SEARCH_PATH = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $TASKBAND_PATH = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
    $TASKBAR_PATH = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*"
    $THEME_PATH = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $CDM_PATH = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $DATA_COLLECTION_PATH = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"

    Set-ItemProperty -Path $THEME_PATH -Name "SystemUsesLightTheme" -Value 0 # Set the system theme to Dark
    Set-ItemProperty -Path $THEME_PATH -Name "AppsUseLightTheme" -Value 0 # Set the app theme to Dark
    Set-ItemProperty -Path $DESKTOP_PATH -Name 'WallPaper' -Value '' # Set the desktop background to a solid color
    Set-ItemProperty -Path $COLORS_PATH -Name 'Background' -Value '0 0 0' # Set the desktop background to a solid color
    Set-ItemProperty -Path $ADVANCED_PATH -Name 'HideIcons' -Value 1 # Hide Desktop Icons
    Set-ItemProperty -Path $ADVANCED_PATH -Name 'ShowTaskViewButton' -Type 'DWord' -Value 0 # Hide Task View
    Set-ItemProperty -Path $ADVANCED_PATH -Name 'TaskbarAl' -Type 'DWord' -Value 0 # Align Taskbar to the left
    Set-ItemProperty -Path $SEARCH_PATH -Name 'SearchBoxTaskbarMode' -Value 0 -Type DWord -Force # Hide Search bar
    Remove-Item -Path $TASKBAR_PATH -Force -Recurse -ErrorAction SilentlyContinue # Unpin all taskbar icons
    Remove-Item -Path $TASKBAND_PATH -Force -Recurse -ErrorAction SilentlyContinue # Unpin all taskbar icons
    Set-ItemProperty -Path $GAMEDVR_PATH -Name 'AppCaptureEnabled' -Value 0 # Disable Game Overlays
    Set-ItemProperty -Path $ADVANCED_PATH -Name 'Hidden' -Value 1 # Show hidden files and folders
    Set-ItemProperty -Path $ADVANCED_PATH -Name 'HideFileExt' -Value 1 # Don't hide file extensions
    Set-ItemProperty -Path $CDM_PATH -Name 'ContentDeliveryAllowed' -Value 1
    Set-ItemProperty -Path $CDM_PATH -Name 'RotatingLockScreenEnabled' -Value 1
    Set-ItemProperty -Path $CDM_PATH -Name 'RotatingLockScreenOverlayEnabled' -Value 0
    Set-ItemProperty -Path $CDM_PATH -Name 'SubscribedContent-338388Enabled' -Value 0
    Set-ItemProperty -Path $CDM_PATH -Name 'SubscribedContent-338389Enabled' -Value 0
    Set-ItemProperty -Path $CDM_PATH -Name 'SubscribedContent-88000326Enabled' -Value 0
    powercfg /change monitor-timeout-ac 0 # Disable monitor timeout

    # Disable telemetry
    Get-Service DiagTrack | Set-Service -StartupType Disabled
    Get-Service dmwappushservice | Set-Service -StartupType Disabled
    Set-ItemProperty -Path $DATA_COLLECTION_PATH -Name "AllowTelemetry" -Type DWord -Value 0

    # Set the lock screen image
    $Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'
    if (!(Test-Path -Path $Key))
    {
        New-Item -Path $Key -Force | Out-Null
    }
    Set-ItemProperty -Path $Key -Name LockScreenImagePath -value "./wallpaper.png"

    # Auto hide the taskbar
    $p = "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    $v = (Get-ItemProperty -Path $p).Settings
    $v[8] = 3
    Set-ItemProperty -Path $p -Name Settings -Value $v
}

# Restart Windows Explorer to apply the changes
function Restart-Explorer
{
    Stop-Process -processName: explorer
    Start-Process explorer
}

## Install WinGet
function Install-WinGet
{
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
    Add-AppxPackage winget.msixbundle
    Remove-Item winget.msixbundle
}

# Install Apps
function Install-Apps
{
    winget install -e --id Microsoft.PowerToys --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Google.Chrome --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id JetBrains.Toolbox --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Spotify.Spotify --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Google.GoogleDrive --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Obsidian.Obsidian --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Discord.Discord --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id TorProject.TorBrowser --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id Figma.Figma --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id 7zip.7zip --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id calibre.calibre --silent --accept-source-agreements --accept-package-agreements
    winget install -e --id SublimeHQ.SublimeText.4 --silent --accept-source-agreements --accept-package-agreements
}

# Interrupt the script if system is not activated
if (-not (Get-IsActivated))
{
    throw "Windows license is not activated. Please activate it before continuing."
}

Write-Output "Starting the setup process..."
Set-Preferences
Restart-Explorer

# Install WinGet
Write-Output "Checking if WinGet is installed..."
try
{
    winget --version | Out-Null
    Write-host "WinGet is already installed."
}
catch
{
    Write-Host "Could not find WinGet. Installing..."
    Install-WinGet
}

## Install Windows Subsystem for Linux
Write-Output "Checking if WSL is installed..."
try
{
    wsl --version | Out-Null
    Write-host "WSL is already installed."
}
catch
{
    Write-Host "Could not find WSL. Installing..."
    wsl --install Ubuntu
}
wsl --set-default-version 2

# Install Apps
Write-Output "Installing apps..."
Install-Apps

Write-Output "Finished the setup process. Logging off to apply the changes..."
Start-Sleep -Seconds 1
for ($i = 3; $i -gt 0; $i--) {
    Write-Output "$i"
    Start-Sleep -Seconds 1
}

# Logoff and login
Write-Output "Done! Please log off and log back in to apply the changes."
