# Error handling
$ErrorActionPreference = "Stop"

# Configure Git
Write-Host "Configuring Git..."
git config --global user.name $env:GIT_USER_NAME
git config --global user.email $env:GIT_USER_EMAIL

# Generate SSH key
$sshDir = Join-Path $env:USERPROFILE ".ssh"
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

$keyPath = Join-Path $sshDir "id_ed25519"

Write-Host "Generating SSH key..."
ssh-keygen -t ed25519 -C $env:GIT_USER_EMAIL -N '""' -f $keyPath

# Start ssh-agent and add key
Write-Host "Adding SSH key to ssh-agent..."
Start-Service ssh-agent -ErrorAction SilentlyContinue
Set-Service -Name ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue

# Add the key using ssh-add
ssh-add $keyPath

Write-Host "Git and SSH configuration complete."
