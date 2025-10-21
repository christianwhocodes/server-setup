# Error handling
$ErrorActionPreference = "Stop"

# Install uv Python package manager
# https://docs.astral.sh/uv/#installation

Write-Host "Installing uv Python package manager..."

# Download and run the uv installer for Windows
Invoke-WebRequest -Uri "https://astral.sh/uv/install.ps1" -UseBasicParsing | Invoke-Expression

Write-Host "uv installation complete."
