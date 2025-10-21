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

# Install Nginx
Write-Host "Installing Nginx..."
choco install nginx -y

# Start Nginx service
Write-Host "Starting Nginx service..."
Start-Service nginx -ErrorAction SilentlyContinue

# Configure Nginx to start automatically
Set-Service -Name nginx -StartupType Automatic -ErrorAction SilentlyContinue

# Configure firewall rules
Write-Host "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "Nginx HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Nginx HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

# Create nginx config directory if it doesn't exist
$nginxConfigDir = "C:\tools\nginx\conf\snippets"
New-Item -ItemType Directory -Force -Path $nginxConfigDir | Out-Null

# Create port-proxy.conf snippet
$portProxyConfig = @'
location / {
    proxy_pass http://127.0.0.1:$upstream_port;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_cache_bypass $http_upgrade;
}
'@

$portProxyPath = Join-Path $nginxConfigDir "port-proxy.conf"
$portProxyConfig | Out-File -FilePath $portProxyPath -Encoding UTF8 -Force

Write-Host "Nginx installation and configuration complete."

### How to use this snippet ###
# In your server block, include the snippet and set the upstream_port variable:
# server {
#     listen 80;
#     server_name your_domain.com;
#     set $upstream_port 8080; # Replace 8080 with your desired port
#     include snippets/port-proxy.conf;
# }
### End of snippet ###
