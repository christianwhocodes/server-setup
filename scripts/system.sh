#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

openssh_setup() {
    echo -e "${BLUE}Setting up OpenSSH and UFW...${NC}"
    
    if ! command -v ufw >/dev/null 2>&1; then
        apt-get install -y ufw || true
    fi

    if command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "Status: inactive"; then
            ufw allow OpenSSH || true
            ufw --force enable || true
        fi
    fi
}

necessary_packages_setup() {
    echo -e "${BLUE}Installing necessary packages...${NC}"
    
    apt install -y \
        git curl wget \
        build-essential software-properties-common \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
        libncursesw5-dev xz-utils tk-dev libxmlsec1-dev \
        libffi-dev liblzma-dev pandoc texlive-xetex \
        libsqlite3-dev sqlite3
}

nginx_setup() {
    echo -e "${BLUE}Setting up Nginx...${NC}"
    
    apt install -y nginx apache2-utils

    if ! command -v ufw >/dev/null 2>&1; then
        apt install -y ufw || true
    fi

    if command -v ufw >/dev/null 2>&1; then
        ufw allow 'Nginx Full' || true
    fi

    systemctl enable --now nginx

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
    
    snap install core && snap refresh core

    apt remove -y certbot || true

    snap install --classic certbot

    ln -sf /snap/bin/certbot /usr/bin/certbot
}

code_server_setup() {
    echo -e "${BLUE}Setting up code-server...${NC}"
    
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
}

postgres_setup() {
    echo -e "${BLUE}Setting up PostgreSQL...${NC}"
    
    apt install -y postgresql postgresql-contrib libpq-dev

    systemctl enable --now postgresql
}

main() {
    echo -e "${BLUE}=== Start Setup (system) Configuration ===${NC}"
    echo ""

    sudo apt-get update -y || true

    openssh_setup
    necessary_packages_setup
    nginx_setup
    certbot_setup
    code_server_setup
    postgres_setup

    echo -e "${GREEN}=== ✅ Finished Setup (system) Configuration ===${NC}"
}

main
