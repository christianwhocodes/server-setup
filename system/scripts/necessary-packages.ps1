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

# Install essential development packages
Write-Host "Installing essential development packages..."

$packages = @(
    "git",
    "curl",
    "wget",
    "visualstudio2022buildtools",
    "openssl",
    "sqlite",
    "pandoc",
    "miktex"
)

foreach ($package in $packages) {
    Write-Host "Installing $package..."
    choco install $package -y
}

Write-Host "Essential packages installation complete."
