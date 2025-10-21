# Error handling
$ErrorActionPreference = "Stop"

# Color functions
function Write-Green { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Blue { param([string]$Message) Write-Host $Message -ForegroundColor Blue }

# Git user email input
Write-Host ""
Write-Blue "=== Git Configuration ==="
$GIT_USER_EMAIL = Read-Host "Enter your git user email (e.g., user@example.com)"
Write-Green "➜ Using git user email: $GIT_USER_EMAIL"
Write-Host ""

# Git user name input
$GIT_USER_NAME = Read-Host "Enter your git user name (e.g., John Doe)"
Write-Green "➜ Using git user name: $GIT_USER_NAME"
Write-Host ""

$SETUP_TYPE = "user"

$TMP_DIR = Join-Path $env:USERPROFILE "foundry\$SETUP_TYPE"
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

Write-Blue "=== Setup ($SETUP_TYPE) Configuration ==="
Write-Host ""

# * Order of execution matters! *
Download-And-Run "code-server.ps1"

$CODE_SERVER_PORT = Get-Content (Join-Path $TMP_DIR "code-server-port.tmp")
$CODE_SERVER_PASS = Get-Content (Join-Path $TMP_DIR "code-server-pass.tmp")

Download-And-Run "uv.ps1" 
Download-And-Run "nvm.ps1"  
Download-And-Run "repos.ps1" 
Download-And-Run "powershell-profile.ps1"

# Set environment variables for git-ssh.ps1
$env:GIT_USER_EMAIL = $GIT_USER_EMAIL
$env:GIT_USER_NAME = $GIT_USER_NAME
Download-And-Run "git-ssh.ps1" 
 
# Cleanup 
Remove-Item -Path $TMP_DIR -Recurse -Force
 
# Final message 
Write-Green "=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===" 
Write-Blue "Code-server is configured to run on port $CODE_SERVER_PORT"
Write-Blue "Code-server password in $env:USERPROFILE\.config\code-server\config.yaml: $CODE_SERVER_PASS"
Write-Blue "SSH public key (add this to your git hosting service):"
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"

# ***************** End *****************
