# PowerShell Conversion Summary

This document provides a summary of the conversion from bash to PowerShell scripts for the Foundry project.

## Overview

All bash scripts have been converted to PowerShell equivalents to enable the Foundry automation scripts to run on Windows systems.

## Converted Files

### System Scripts (Administrator Required)
- `system/setup.sh` → `system/setup.ps1`
- `system/scripts/nginx.sh` → `system/scripts/nginx.ps1`
- `system/scripts/certbot.sh` → `system/scripts/certbot.ps1`
- `system/scripts/code-server.sh` → `system/scripts/code-server.ps1`
- `system/scripts/postgres.sh` → `system/scripts/postgres.ps1`
- `system/scripts/necessary-packages.sh` → `system/scripts/necessary-packages.ps1`

### User Scripts (Non-Administrator)
- `user/setup.sh` → `user/setup.ps1`
- `user/scripts/code-server.sh` → `user/scripts/code-server.ps1`
- `user/scripts/uv.sh` → `user/scripts/uv.ps1`
- `user/scripts/nvm.sh` → `user/scripts/nvm.ps1`
- `user/scripts/repos.sh` → `user/scripts/repos.ps1`
- `user/scripts/bash-aliases.sh` → `user/scripts/powershell-profile.ps1`
- `user/scripts/git-ssh.sh` → `user/scripts/git-ssh.ps1`

## Key Changes

### Package Management
- **Linux (APT)** → **Windows (Chocolatey)**
  - All system packages are now installed via Chocolatey
  - Chocolatey is automatically installed if not present

### Service Management
- **systemctl** → **Windows Services**
  - Services are managed using `Start-Service`, `Stop-Service`, `Get-Service`
  - NSSM is recommended for running code-server as a Windows service

### Path Differences
- **Linux paths** (`/home/$USER`) → **Windows paths** (`$env:USERPROFILE`)
- **Unix directory separators** (`/`) → **Windows-compatible** (PowerShell handles both)

### Shell Configuration
- **~/.bashrc and ~/.bash_aliases** → **PowerShell Profile**
  - Aliases converted to PowerShell functions and aliases
  - Profile located at `$PROFILE.CurrentUserAllHosts`

### Tool Equivalents
- **nvm (Linux)** → **nvm-windows**
- **apt packages** → **Chocolatey packages**
- **systemctl** → **Windows Service cmdlets**

## PowerShell-Specific Features

### Error Handling
All scripts use `$ErrorActionPreference = "Stop"` for consistent error handling

### Color Output
Color functions implemented using `Write-Host` with `-ForegroundColor` parameter

### Administrator Checks
System scripts use `#Requires -RunAsAdministrator` directive

### Port Detection
PowerShell equivalent of port checking using `Get-NetTCPConnection`

## Testing

All PowerShell scripts have been validated for:
- ✓ Valid PowerShell syntax
- ✓ Proper script structure
- ✓ Consistent error handling

## Usage

### System Setup (Administrator)
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/christianwhocodes/foundry/main/system/setup.ps1" -UseBasicParsing).Content
```

### User Setup (Regular User)
```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.ps1" -UseBasicParsing).Content
```

## Compatibility Notes

- Requires Windows 10/11 or Windows Server
- Requires PowerShell 5.1 or later
- Administrator access required for system setup
- Internet connection required for downloading packages

## Migration Guide

For users currently using the bash scripts on Linux, the PowerShell scripts provide equivalent functionality on Windows with the following mappings:

| Linux Command | Windows PowerShell Function |
|--------------|----------------------------|
| `update` | `update` (via Chocolatey) |
| `editaliases` | `editprofile` |
| `refresh` | `refresh` |
| `repos` | `repos` |
| `nginx start/stop/restart` | `nginx start/stop/restart` |
| `postgres start/stop/restart` | `postgres start/stop/restart` |

All custom functions from bash-aliases.sh have been ported to the PowerShell profile with equivalent or enhanced functionality.
