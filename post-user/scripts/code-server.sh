#!/bin/bash
set -e

# Color variables
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${RED}❌ DOMAIN_NAME environment variable is required${NC}"
    exit 1
fi

systemctl enable --now code-server@developer

# Initial message to explain what's happening
echo -e "${BLUE}=== Code Server & Nginx Configuration for $DOMAIN_NAME ===${NC}"
echo -e "${BLUE}Note: If you're re-running this script, we'll first clean up any existing configuration${NC}"
echo -e "${BLUE}      to ensure a fresh setup. This is normal and prevents conflicts.${NC}"
echo ""

# Cleanup existing configuration (if it exists)
echo -e "${BLUE}➜ Checking for existing configuration...${NC}"

# Revoke existing SSL certificate (ignore errors if doesn't exist)
if certbot certificates 2>/dev/null | grep -q "Certificate Name: $DOMAIN_NAME"; then
    echo -e "${YELLOW}  → Found existing SSL certificate, revoking it...${NC}"
    certbot revoke --cert-name $DOMAIN_NAME --non-interactive --agree-tos --delete-after-revoke || true
fi

# Remove nginx symlink (ignore errors if doesn't exist)
if [ -L "/etc/nginx/sites-enabled/$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}  → Found existing nginx symlink, removing it...${NC}"
    unlink "/etc/nginx/sites-enabled/$DOMAIN_NAME"
fi

# Remove nginx config file (ignore errors if doesn't exist)
if [ -f "/etc/nginx/sites-available/$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}  → Found existing nginx config, removing it...${NC}"
    rm -f "/etc/nginx/sites-available/$DOMAIN_NAME"
fi

# Test nginx config after cleanup
nginx -t
systemctl reload nginx

echo "Creating new nginx configuration..."

# Read the port number from temporary file
CODE_SERVER_PORT=$(cat /tmp/code-server-port.tmp)

# Validate that we got a port number
if [ -z "$CODE_SERVER_PORT" ]; then
    echo -e "${RED}❌ Failed to read port number from temporary file${NC}"
    exit 1
fi

# Use the port in nginx configuration
cat > /etc/nginx/sites-available/$DOMAIN_NAME << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;

    set \$code_server_port $CODE_SERVER_PORT;
    include snippets/code-server-proxy.conf;
}
EOF

echo "Enabling nginx site and setting up SSL..."

ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
certbot --nginx -d $DOMAIN_NAME --non-interactive --agree-tos --redirect
systemctl reload nginx