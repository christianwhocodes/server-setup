#!/bin/bash
# This script contains modular system setup functions
# Functions are meant to be sourced and called individually for idempotent operations
# The calling context should use 'set -e' to ensure errors are properly handled

set -e

export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

openssh_setup() {
  echo -e "${BLUE}Setting up OpenSSH and UFW...${NC}"

  if ! command -v ufw >/dev/null 2>&1; then
    if ! apt-get install -y ufw; then
      echo -e "${RED}⚠️  Warning: Failed to install ufw${NC}"
      return 0
    fi
  fi

  if command -v ufw >/dev/null 2>&1; then
    # Check if OpenSSH rule already exists
    if ! ufw status | grep -q "OpenSSH.*ALLOW"; then
      echo -e "${YELLOW}Adding OpenSSH rule to UFW...${NC}"
      if ! ufw allow OpenSSH; then
        echo -e "${RED}⚠️  Warning: Failed to allow OpenSSH in ufw${NC}"
        return 0
      fi
    else
      echo -e "${GREEN}✅ OpenSSH rule already exists in UFW${NC}"
    fi
    
    # Verify the rule was actually added before enabling
    if ufw status | grep -q "OpenSSH.*ALLOW"; then
      if ufw status | grep -q "Status: inactive"; then
        echo -e "${YELLOW}Enabling UFW firewall...${NC}"
        if ! ufw --force enable; then
          echo -e "${RED}⚠️  Warning: Failed to enable ufw${NC}"
          return 0
        fi
        echo -e "${GREEN}✅ UFW enabled successfully${NC}"
      else
        echo -e "${GREEN}✅ UFW already enabled${NC}"
      fi
    else
      echo -e "${RED}❌ Error: OpenSSH rule not confirmed in UFW, skipping enable${NC}"
      echo -e "${RED}   This is a safety measure to prevent lockout${NC}"
      return 1
    fi
  fi
}

necessary_packages_setup() {
  echo -e "${BLUE}Installing necessary packages...${NC}"

  if ! apt install -y \
    git curl wget \
    build-essential software-properties-common \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libncursesw5-dev xz-utils tk-dev libxmlsec1-dev \
    libffi-dev liblzma-dev pandoc texlive-xetex \
    libsqlite3-dev sqlite3; then
    echo -e "${RED}❌ Failed to install necessary packages${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}✅ All packages installed successfully${NC}"
}

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

certbot_setup() {
  echo -e "${BLUE}Setting up Certbot...${NC}"

  if ! command -v snap >/dev/null 2>&1; then
    echo -e "${RED}❌ snapd is not installed${NC}"
    exit 1
  fi

  # Check if certbot is already installed via snap
  if snap list certbot >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Certbot already installed${NC}"
    return 0
  fi

  if ! snap install core; then
    echo -e "${RED}❌ Failed to install snap core${NC}"
    exit 1
  fi

  snap refresh core

  # Remove apt version if it exists
  apt remove -y certbot 2>/dev/null || true

  if ! snap install --classic certbot; then
    echo -e "${RED}❌ Failed to install certbot${NC}"
    exit 1
  fi

  ln -sf /snap/bin/certbot /usr/bin/certbot
  
  echo -e "${GREEN}✅ Certbot installed successfully${NC}"
}

code_server_setup() {
  echo -e "${BLUE}Setting up code-server...${NC}"

  # Check if code-server is already installed
  if command -v code-server >/dev/null 2>&1; then
    echo -e "${GREEN}✅ code-server already installed${NC}"
  else
    if ! curl -fsSL https://code-server.dev/install.sh | sh; then
      echo -e "${RED}❌ Failed to install code-server${NC}"
      exit 1
    fi

    # Verify code-server was installed
    if ! command -v code-server >/dev/null 2>&1; then
      echo -e "${RED}❌ code-server command not found after installation${NC}"
      exit 1
    fi

    echo -e "${GREEN}✅ code-server installed successfully${NC}"
  fi

  # Note: code-server-proxy.conf snippet is now created in nginx_setup
  # This ensures it's available if nginx is installed, even if code-server isn't
  echo -e "${GREEN}✅ code-server system setup completed${NC}"
}

postgres_setup() {
  echo -e "${BLUE}Setting up PostgreSQL...${NC}"

  # Check if PostgreSQL is already installed
  if command -v psql >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL already installed${NC}"
  else
    if ! apt install -y postgresql postgresql-contrib libpq-dev; then
      echo -e "${RED}❌ Failed to install PostgreSQL${NC}"
      exit 1
    fi
  fi

  if ! systemctl is-enabled --quiet postgresql 2>/dev/null; then
    if ! systemctl enable postgresql; then
      echo -e "${RED}❌ Failed to enable PostgreSQL${NC}"
      exit 1
    fi
  fi

  if ! systemctl is-active --quiet postgresql; then
    if ! systemctl start postgresql; then
      echo -e "${RED}❌ Failed to start PostgreSQL${NC}"
      exit 1
    fi
  fi

  echo -e "${GREEN}✅ PostgreSQL is running${NC}"
}
