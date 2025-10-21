# Error handling
$ErrorActionPreference = "Stop"

# Color functions
function Write-Green { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Blue { param([string]$Message) Write-Host $Message -ForegroundColor Blue }
function Write-Red { param([string]$Message) Write-Host $Message -ForegroundColor Red }

# Function to check if a port is in use
function Test-PortInUse {
    param([int]$Port)
    
    $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return ($null -ne $connections)
}

# Function to find an available port
function Find-AvailablePort {
    param(
        [int]$StartPort,
        [int]$EndPort
    )
    
    for ($port = $StartPort; $port -le $EndPort; $port++) {
        if (-not (Test-PortInUse -Port $port)) {
            return $port
        }
    }
    return $null
}

# Configure port
Write-Blue "Checking for available ports in range 8080-8100..."
$PORT = Find-AvailablePort -StartPort 8080 -EndPort 8100

if ($null -eq $PORT) {
    Write-Red "❌ No available ports found in range 8080-8100"
    exit 1
}

Write-Green "✅ Found available port: $PORT"

# Generate random password
$RANDOM_PASS = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Get parent TMP_DIR from environment or use default
$TMP_DIR = $env:TMP_DIR
if ([string]::IsNullOrEmpty($TMP_DIR)) {
    $TMP_DIR = Join-Path $env:USERPROFILE "foundry\user"
}

# Write config values to temp files for parent script
$RANDOM_PASS | Out-File -FilePath (Join-Path $TMP_DIR "code-server-pass.tmp") -Encoding UTF8 -NoNewline
$PORT | Out-File -FilePath (Join-Path $TMP_DIR "code-server-port.tmp") -Encoding UTF8 -NoNewline

# Create temp directory for code-server port
$tempCodeServerDir = Join-Path $env:TEMP "code-server-port"
New-Item -ItemType Directory -Force -Path $tempCodeServerDir | Out-Null

$portTempFile = Join-Path $tempCodeServerDir "$env:USERNAME.tmp"
$PORT | Out-File -FilePath $portTempFile -Encoding UTF8 -NoNewline

# Configure code-server
$configDir = Join-Path $env:USERPROFILE ".config\code-server"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

$configPath = Join-Path $configDir "config.yaml"
$configContent = @"
bind-addr: 127.0.0.1:$PORT
auth: password
password: $RANDOM_PASS
cert: false
"@

$configContent | Out-File -FilePath $configPath -Encoding UTF8 -Force

Write-Host "code-server configuration complete."
