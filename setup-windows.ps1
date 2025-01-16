#Requires -RunAsAdministrator

# Removes the restrictions on PowerShell execution
Set-ExecutionPolicy Unrestricted

# Activates Windows
Invoke-RestMethod https://get.activated.win | Invoke-Expression

# Sets the system and app theme to Dark
$THEME_PATH = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $THEME_PATH -Name "SystemUsesLightTheme" -Value 0
Set-ItemProperty -Path $THEME_PATH -Name "AppsUseLightTheme" -Value 0

# Sets the desktop background to a solid color
$DESKTOP_PATH = 'HKCU:\Control Panel\Desktop'
$COLORS_PATH = 'HKCU:\Control Panel\Colors'
Set-ItemProperty -Path $DESKTOP_PATH -Name 'WallPaper' -Value ''
Set-ItemProperty -Path $COLORS_PATH -Name 'Background' -Value '0 0 0'

# Hides the icons in the desktop
$ADVANCED_PATH = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty -Path $ADVANCED_PATH -Name 'HideIcons' -Value 1

# Hides the Task View button
Set-ItemProperty -Path $ADVANCED_PATH -Name 'ShowTaskViewButton' -Type 'DWord' -Value 0

# Aligns the taskbar icons to the left
Set-ItemProperty -Path $ADVANCED_PATH -Name 'TaskbarAl' -Type 'DWord' -Value 0

# Unpin all taskbar icons
Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Force -Recurse -ErrorAction SilentlyContinue

# Hides the search box in the taskbar
$SEARCH_PATH = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
Set-ItemProperty -Path $SEARCH_PATH -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

# Install WinGet
$WINGET_URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$WINGET_URL = (Invoke-WebRequest -Uri $WINGET_URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"
Invoke-WebRequest -Uri $WINGET_URL -OutFile "Setup.msix" -UseBasicParsing
Add-AppxPackage -Path "Setup.msix"
Remove-Item "Setup.msix"

## Install Windows Subsystem for Linux
wsl --install Ubuntu
wsl --set-default-version 2

# Reloads the system theme by stopping and restarting the explorer process. It starts automatically.
Stop-Process -processName: explorer

# Logoff and login
LOGOUT