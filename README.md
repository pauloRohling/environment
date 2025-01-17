# Environment

This repository contains scripts to configure my development environment.

## Activate Windows

Activate Windows using activation scripts from [massgravel/Microsoft-Activation-Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts).

```powershell
.\activate-windows.ps1
```

## Install apps

After the activation, run the setup script to apply the preferences and install the required software.

```powershell
.\setup-windows.ps1
```

## PowerToys configuration

With [PowerToys](https://github.com/microsoft/PowerToys) extension installed, restore the configurations' backup file on `./powertoys`.
