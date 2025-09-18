#!/bin/bash
set -e

DOMAIN_NAME=$1

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: Domain name is required"
    exit 1
fi

systemctl enable --now code-server@developer

# Create nginx config
cat > /etc/nginx/sites-available/$DOMAIN_NAME << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;

    set $code_server_port 8080;
    include snippets/code-server-proxy.conf;
}
EOF

ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
certbot --nginx -d $DOMAIN_NAME
systemctl reload nginx