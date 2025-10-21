# Error handling
$ErrorActionPreference = "Stop"

# Install nvm for Windows
# https://github.com/coreybutler/nvm-windows

Write-Host "Installing nvm for Windows..."

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install nvm-windows
choco install nvm -y

Write-Host "nvm installation complete."
Write-Host "Note: You may need to restart your terminal for nvm to be available."
