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

# Install PostgreSQL
Write-Host "Installing PostgreSQL..."
choco install postgresql -y --params '/Password:postgres'

# Enable and start PostgreSQL service
Write-Host "Configuring PostgreSQL service..."
Set-Service -Name postgresql-x64-* -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name postgresql-x64-* -ErrorAction SilentlyContinue

Write-Host "PostgreSQL installation complete."
Write-Host "Default password for postgres user is: postgres"
Write-Host "Please change it after first login for security."
