# Error handling
$ErrorActionPreference = "Stop"

# Color functions
function Write-Green { param([string]$Message) Write-Host $Message -ForegroundColor Green }
function Write-Red { param([string]$Message) Write-Host $Message -ForegroundColor Red }

# Backup existing PowerShell profile if it exists
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profilePath

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}

if (Test-Path $profilePath) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = "$profilePath.backup.$timestamp"
    Copy-Item $profilePath $backupPath
    Write-Host "Backed up existing PowerShell profile to: $backupPath"
}

# Create new PowerShell profile
$profileContent = @'
# ======= Misc =======
function Update-System {
    Write-Host "Updating Chocolatey packages..."
    choco upgrade all -y
}
Set-Alias -Name update -Value Update-System

function Edit-Profile {
    notepad $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name editprofile -Value Edit-Profile

function Refresh-Profile {
    . $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name refresh -Value Refresh-Profile

function Show-Profile {
    Get-Content $PROFILE.CurrentUserAllHosts
}
Set-Alias -Name showprofile -Value Show-Profile

Set-Alias -Name la -Value Get-ChildItem

function Serve-Directory {
    param([int]$Port = 3000)
    npx serve --no-clipboard -l $Port
}
Set-Alias -Name serve -Value Serve-Directory

function Go-Repos {
    $reposPath = Join-Path $env:USERPROFILE "repos"
    if (Test-Path $reposPath) {
        Set-Location $reposPath
    } else {
        Write-Host "Directory $reposPath does not exist" -ForegroundColor Red
    }
}
Set-Alias -Name repos -Value Go-Repos

# ======= Python & Virtualenv =======
function New-VirtualEnv {
    python -m venv .\.venv
}
Set-Alias -Name createvenv -Value New-VirtualEnv

function Enable-VirtualEnv {
    .\.venv\Scripts\Activate.ps1
}
Set-Alias -Name activatevenv -Value Enable-VirtualEnv

# ======= Django =======
function Invoke-Django {
    param([Parameter(ValueFromRemainingArguments)]$Arguments)
    
    if (Test-Path "poetry.lock") {
        poetry run python manage.py @Arguments
    } elseif (Test-Path "Pipfile") {
        pipenv run python manage.py @Arguments
    } else {
        python manage.py @Arguments
    }
}
Set-Alias -Name d -Value Invoke-Django

# Run Django development server on localhost (127.0.0.1), default port 8000
function Start-DjangoLocal {
    param([int]$Port = 8000)
    Invoke-Django runserver "127.0.0.1:$Port"
}
Set-Alias -Name drun -Value Start-DjangoLocal

# Run Django development server on 0.0.0.0 (accessible from network), default port 8000
function Start-DjangoNetwork {
    param([int]$Port = 8000)
    Invoke-Django runserver "0.0.0.0:$Port"
}
Set-Alias -Name drun0 -Value Start-DjangoNetwork

# ======= PostgreSQL =======
function Manage-PostgreSQL {
    param([string]$Action = "status")
    
    $serviceName = Get-Service -Name "postgresql*" | Select-Object -First 1 -ExpandProperty Name
    
    switch ($Action) {
        "start" { Start-Service $serviceName }
        "stop" { Stop-Service $serviceName }
        "restart" { Restart-Service $serviceName }
        "status" { Get-Service $serviceName | Format-Table -AutoSize }
        default { Write-Host "Usage: postgres [start|stop|restart|status]" }
    }
}
Set-Alias -Name postgres -Value Manage-PostgreSQL

# ======= Nginx =======
function Show-NginxErrorLog {
    $logPath = "C:\tools\nginx\logs\error.log"
    if (Test-Path $logPath) {
        notepad $logPath
    } else {
        Write-Host "Nginx error log not found at: $logPath" -ForegroundColor Red
    }
}
Set-Alias -Name nginxerrorlog -Value Show-NginxErrorLog

function Go-SitesAvailable {
    Set-Location "C:\tools\nginx\conf\sites-available"
}
Set-Alias -Name sitesavailable -Value Go-SitesAvailable

function Go-SitesEnabled {
    Set-Location "C:\tools\nginx\conf\sites-enabled"
}
Set-Alias -Name sitesenabled -Value Go-SitesEnabled

function Manage-Nginx {
    param([string]$Action = "status")
    
    switch ($Action) {
        "start" { Start-Service nginx }
        "stop" { Stop-Service nginx }
        "restart" { Restart-Service nginx }
        "status" { Get-Service nginx | Format-Table -AutoSize }
        default { Write-Host "Usage: nginx [start|stop|restart|status]" }
    }
}
Set-Alias -Name nginx -Value Manage-Nginx

function Test-NginxConfig {
    & "C:\tools\nginx\nginx.exe" -t
}
Set-Alias -Name tnginx -Value Test-NginxConfig

function Edit-NginxSite {
    param([string]$SiteName)
    
    if ([string]::IsNullOrEmpty($SiteName)) {
        Write-Host "Usage: nginxedit <site-name>" -ForegroundColor Red
        return
    }
    
    $sitePath = "C:\tools\nginx\conf\sites-available\$SiteName"
    notepad $sitePath
}
Set-Alias -Name nginxedit -Value Edit-NginxSite

function Enable-NginxSite {
    param([string]$SiteName)
    
    if ([string]::IsNullOrEmpty($SiteName)) {
        Write-Host "Usage: nginxlink <site-name>" -ForegroundColor Red
        return
    }
    
    $sourcePath = "C:\tools\nginx\conf\sites-available\$SiteName"
    $linkPath = "C:\tools\nginx\conf\sites-enabled\$SiteName"
    
    if (Test-Path $sourcePath) {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $sourcePath -Force
        Write-Host "Enabled site: $SiteName" -ForegroundColor Green
    } else {
        Write-Host "Site not found: $sourcePath" -ForegroundColor Red
    }
}
Set-Alias -Name nginxlink -Value Enable-NginxSite

function Disable-NginxSite {
    param([string]$SiteName)
    
    if ([string]::IsNullOrEmpty($SiteName)) {
        Write-Host "Usage: nginxunlink <site-name>" -ForegroundColor Red
        return
    }
    
    $linkPath = "C:\tools\nginx\conf\sites-enabled\$SiteName"
    
    if (Test-Path $linkPath) {
        Remove-Item $linkPath -Force
        Write-Host "Disabled site: $SiteName" -ForegroundColor Green
    } else {
        Write-Host "Site link not found: $linkPath" -ForegroundColor Red
    }
}
Set-Alias -Name nginxunlink -Value Disable-NginxSite

# ======= Code Server =======
function Update-CodeServer {
    choco upgrade code-server -y
}
Set-Alias -Name code_server_update -Value Update-CodeServer

# ======= File Management =======
# Remove files/folders recursively with confirmation
# Usage examples:
#   Remove-Recursively -FolderPath .\src -Pattern *.pyc       # Remove all .pyc files in src directory
#   Remove-Recursively -FolderPath . -Pattern node_modules -Directory # Remove all node_modules directories
#   Remove-Recursively -FolderPath . -Pattern .git -Directory -Force # Force remove all .git directories
function Remove-Recursively {
    param(
        [Parameter(Mandatory)]
        [string]$FolderPath,
        
        [Parameter(Mandatory)]
        [string]$Pattern,
        
        [switch]$Directory,
        [switch]$Force
    )
    
    $targetType = if ($Directory) { "directory" } else { "file" }
    
    # Safety check for critical directories
    $resolvedPath = Resolve-Path $FolderPath -ErrorAction SilentlyContinue
    if ($resolvedPath -and ($resolvedPath.Path -eq "C:\" -or $resolvedPath.Path -eq $env:USERPROFILE)) {
        Write-Host "⚠️  Error: Refusing to delete files in '$($resolvedPath.Path)' (to prevent system damage)." -ForegroundColor Red
        return
    }
    
    Write-Host "🛑 You are about to delete items in: $FolderPath" -ForegroundColor Yellow
    if ($Directory) {
        Write-Host "📁 Target: All directories named '$Pattern'" -ForegroundColor Yellow
    } else {
        Write-Host "📄 Target: All files matching '$Pattern'" -ForegroundColor Yellow
    }
    
    if (-not $Force) {
        $confirm = Read-Host "❓ Are you sure? (y/N)"
        if ($confirm -notmatch '^[Yy]$') {
            Write-Host "❌ Deletion cancelled." -ForegroundColor Red
            return
        }
    }
    
    try {
        if ($Directory) {
            Get-ChildItem -Path $FolderPath -Directory -Recurse -Filter $Pattern -ErrorAction SilentlyContinue | 
                Remove-Item -Recurse -Force
        } else {
            Get-ChildItem -Path $FolderPath -File -Recurse -Filter $Pattern -ErrorAction SilentlyContinue | 
                Remove-Item -Force
        }
        Write-Host "✅ Deletion complete." -ForegroundColor Green
    } catch {
        Write-Host "❌ Error during deletion: $_" -ForegroundColor Red
    }
}
'@

# Write the profile content
$profileContent | Out-File -FilePath $profilePath -Encoding UTF8 -Force

Write-Host "PowerShell profile path: $profilePath"

# Verify the file can be loaded
try {
    . $profilePath
    Write-Green "✅ Syntax check passed!"
} catch {
    Write-Red "❌ Syntax check failed. Please review the file."
    Write-Red $_.Exception.Message
}

Write-Host "PowerShell profile configuration complete."
Write-Host "Run 'refresh' or restart your PowerShell session to load the new profile."
