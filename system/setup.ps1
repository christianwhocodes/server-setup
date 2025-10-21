#Requires -RunAsAdministrator

# ************ Input, Variables & Functions ************

# Error handling
$ErrorActionPreference = "Stop"

# Color functions
function Write-Green { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Blue { param([string]$Message) Write-Host $Message -ForegroundColor Blue }

$SETUP_TYPE = "system"

$TMP_DIR = "$env:TEMP\foundry\$SETUP_TYPE"
New-Item -ItemType Directory -Force -Path $TMP_DIR | Out-Null

$BASE_URL = "https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts"

function Download-And-Run {
    param([string]$Script)
    
    $tmp_file = Join-Path $TMP_DIR $Script
    $url = "$BASE_URL/$Script"
    
    Write-Host "Downloading $Script..."
    Invoke-WebRequest -Uri $url -OutFile $tmp_file -UseBasicParsing
    
    Write-Host "Running $Script..."
    & PowerShell.exe -ExecutionPolicy Bypass -File $tmp_file
    
    if ($LASTEXITCODE -ne 0) {
        throw "Script $Script failed with exit code $LASTEXITCODE"
    }
}

# ***************** Run Scripts *****************

Write-Blue "=== Start Setup ($SETUP_TYPE) Configuration ==="
Write-Host ""

# * Order of execution matters! * 
Download-And-Run "nginx.ps1"
Download-And-Run "certbot.ps1"
Download-And-Run "code-server.ps1"
Download-And-Run "postgres.ps1"
Download-And-Run "necessary-packages.ps1"

# Cleanup
Remove-Item -Path $TMP_DIR -Recurse -Force

# Final message
Write-Green "=== ✅ Finished Setup ($SETUP_TYPE) Configuration ==="

# ***************** End *****************
