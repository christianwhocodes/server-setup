#!/bin/bash
set -e

apt install -y nginx apache2-utils
systemctl enable --now nginx
ufw allow 'Nginx Full'
rm -f /etc/nginx/snippets/port-proxy.conf
touch /etc/nginx/snippets/port-proxy.conf
cat > /etc/nginx/snippets/port-proxy.conf << 'EOF'
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
EOF

### How to use this snippet ###
# In your server block, include the snippet and set the upstream_port variable:
# server {
#     listen 80;
#     server_name your_domain.com;
#     set $upstream_port 8080; # Replace 8080 with your desired port
#     include snippets/port-proxy.conf;
# }
### End of snippet ###