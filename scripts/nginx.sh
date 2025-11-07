#!/bin/bash
# Nginx setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

nginx_setup() {
  echo -e "${BLUE}Setting up Nginx...${NC}"

  # Check if nginx is already installed
  if ! command -v nginx >/dev/null 2>&1; then
    if ! apt install -y nginx; then
      echo -e "${RED}❌ Failed to install Nginx${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}✅ Nginx already installed${NC}"
  fi

  if ! command -v ufw >/dev/null 2>&1; then
    if ! apt install -y ufw; then
      echo -e "${RED}⚠️  Warning: Failed to install ufw${NC}"
    fi
  fi

  if command -v ufw >/dev/null 2>&1; then
    # Check if Nginx Full rule already exists
    if ! ufw status | grep -q "Nginx Full.*ALLOW"; then
      if ! ufw allow 'Nginx Full'; then
        echo -e "${RED}⚠️  Warning: Failed to allow Nginx in ufw${NC}"
      fi
    fi
  fi

  if ! systemctl is-enabled --quiet nginx 2>/dev/null; then
    if ! systemctl enable nginx; then
      echo -e "${RED}❌ Failed to enable Nginx${NC}"
      exit 1
    fi
  fi

  if ! systemctl is-active --quiet nginx; then
    if ! systemctl start nginx; then
      echo -e "${RED}❌ Failed to start Nginx${NC}"
      exit 1
    fi
  fi

  echo -e "${GREEN}✅ Nginx is running${NC}"

  # Create or update snippet files
  mkdir -p /etc/nginx/snippets
  
  cat > /etc/nginx/snippets/port-proxy.conf <<'EOF'
location / {
    proxy_pass http://127.0.0.1:$upstream_port;
    include proxy_params;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_cache_bypass $http_upgrade;
}
EOF

  cat > /etc/nginx/snippets/code-server-proxy.conf <<'EOF'
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

  # Validate nginx configuration
  if ! nginx -t 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Nginx configuration test failed${NC}"
    echo -e "${YELLOW}   You may need to check /etc/nginx/nginx.conf${NC}"
  else
    echo -e "${GREEN}✅ Nginx configuration is valid${NC}"
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  nginx_setup
fi
