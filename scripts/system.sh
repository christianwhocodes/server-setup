#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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
        if ufw status | grep -q "Status: inactive"; then
            if ! ufw allow OpenSSH; then
                echo -e "${RED}⚠️  Warning: Failed to allow OpenSSH in ufw${NC}"
            fi
            if ! ufw --force enable; then
                echo -e "${RED}⚠️  Warning: Failed to enable ufw${NC}"
            fi
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
}

nginx_setup() {
    echo -e "${BLUE}Setting up Nginx...${NC}"

    if ! apt install -y nginx apache2-utils; then
        echo -e "${RED}❌ Failed to install Nginx${NC}"
        exit 1
    fi

    if ! command -v ufw >/dev/null 2>&1; then
        if ! apt install -y ufw; then
            echo -e "${RED}⚠️  Warning: Failed to install ufw${NC}"
        fi
    fi

    if command -v ufw >/dev/null 2>&1; then
        if ! ufw allow 'Nginx Full'; then
            echo -e "${RED}⚠️  Warning: Failed to allow Nginx in ufw${NC}"
        fi
    fi

    if ! systemctl enable --now nginx; then
        echo -e "${RED}❌ Failed to enable/start Nginx${NC}"
        exit 1
    fi

    # Verify nginx is running
    if ! systemctl is-active --quiet nginx; then
        echo -e "${RED}❌ Nginx failed to start${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Nginx is running${NC}"

    rm -f /etc/nginx/snippets/port-proxy.conf
    touch /etc/nginx/snippets/port-proxy.conf
    cat > /etc/nginx/snippets/port-proxy.conf << 'EOF'
location / {
    proxy_pass http://127.0.0.1:$upstream_port;
    include proxy_params;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_cache_bypass $http_upgrade;
}
EOF
}

certbot_setup() {
    echo -e "${BLUE}Setting up Certbot...${NC}"

    if ! command -v snap >/dev/null 2>&1; then
        echo -e "${RED}❌ snapd is not installed${NC}"
        exit 1
    fi

    if ! snap install core; then
        echo -e "${RED}❌ Failed to install snap core${NC}"
        exit 1
    fi

    snap refresh core

    apt remove -y certbot 2>/dev/null || true

    if ! snap install --classic certbot; then
        echo -e "${RED}❌ Failed to install certbot${NC}"
        exit 1
    fi

    ln -sf /snap/bin/certbot /usr/bin/certbot
}

code_server_setup() {
    echo -e "${BLUE}Setting up code-server...${NC}"

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
}

postgres_setup() {
    echo -e "${BLUE}Setting up PostgreSQL...${NC}"

    if ! apt install -y postgresql postgresql-contrib libpq-dev; then
        echo -e "${RED}❌ Failed to install PostgreSQL${NC}"
        exit 1
    fi

    if ! systemctl enable --now postgresql; then
        echo -e "${RED}❌ Failed to enable/start PostgreSQL${NC}"
        exit 1
    fi

    # Verify postgres is running
    if ! systemctl is-active --quiet postgresql; then
        echo -e "${RED}❌ PostgreSQL failed to start${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ PostgreSQL is running${NC}"
}

main() {
    echo -e "${BLUE}=== Start Setup (system) Configuration ===${NC}"
    echo ""

    if ! apt-get update -y; then
        echo -e "${RED}❌ Failed to update package lists${NC}"
        exit 1
    fi

    openssh_setup
    necessary_packages_setup
    nginx_setup
    certbot_setup
    code_server_setup
    postgres_setup

    echo -e "${GREEN}=== ✅ Finished Setup (system) Configuration ===${NC}"
}

main
