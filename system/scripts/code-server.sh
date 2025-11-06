#!/bin/bash
set -e

curl -fsSL https://code-server.dev/install.sh | sh

rm -f /etc/nginx/snippets/code-server-proxy.conf
touch /etc/nginx/snippets/code-server-proxy.conf
cat > /etc/nginx/snippets/code-server-proxy.conf << 'EOF'
location / {
    proxy_pass http://127.0.0.1:$code_server_port;
    include proxy_params;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_cache_bypass $http_upgrade;
    proxy_buffering off;
}
EOF

### How to use this snippet ###
# See script code-server.sh (post-user) for usage example
# In your server block, include the snippet and set the upstream_port variable:
# server {
#     listen 80;
#     server_name your_domain.com;
#     set $code_server_port 8080; # Replace 8080 with your desired port
#     include snippets/code-server-proxy.conf;
# }
### End of snippet ###