# Error handling
$ErrorActionPreference = "Stop"

# Create repos directory
$reposDir = Join-Path $env:USERPROFILE "repos"
New-Item -ItemType Directory -Force -Path $reposDir | Out-Null

Write-Host "Created repos directory at: $reposDir"
