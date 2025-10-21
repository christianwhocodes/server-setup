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

# Install code-server
Write-Host "Installing code-server..."
choco install code-server -y

# Create nginx config snippet directory if it doesn't exist
$nginxConfigDir = "C:\tools\nginx\conf\snippets"
New-Item -ItemType Directory -Force -Path $nginxConfigDir | Out-Null

# Create code-server-proxy.conf snippet
$codeServerProxyConfig = @'
location / {
    proxy_pass http://127.0.0.1:$code_server_port;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
}
'@

$codeServerProxyPath = Join-Path $nginxConfigDir "code-server-proxy.conf"
$codeServerProxyConfig | Out-File -FilePath $codeServerProxyPath -Encoding UTF8 -Force

Write-Host "code-server installation complete."

### How to use this snippet ###
# See script code-server.ps1 (post-user) for usage example
# In your server block, include the snippet and set the upstream_port variable:
# server {
#     listen 80;
#     server_name your_domain.com;
#     set $code_server_port 8080; # Replace 8080 with your desired port
#     include snippets/code-server-proxy.conf;
# }
### End of snippet ###
