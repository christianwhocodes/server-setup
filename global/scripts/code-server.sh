#!/bin/bash
set -e

curl -fsSL https://code-server.dev/install.sh | sh
rm -f /etc/nginx/snippets/code-server-proxy.conf
touch /etc/nginx/snippets/code-server-proxy.conf
cat > /etc/nginx/snippets/code-server-proxy.conf << 'EOF'
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
EOF
