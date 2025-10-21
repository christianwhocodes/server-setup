#Requires -RunAsAdministrator

# Error handling
$ErrorActionPreference = "Stop"

# Install Chocolatey if not already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install certbot
Write-Host "Installing Certbot..."
choco install certbot -y

Write-Host "Certbot installation complete."
Write-Host "Note: On Windows, certbot works differently than on Linux."
Write-Host "You may need to configure it manually for your specific web server."
