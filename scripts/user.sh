#!/bin/bash 
set -e 

export DEBIAN_FRONTEND=noninteractive 

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

is_port_in_use() {
    local port=$1
    if ss -tuln | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

find_available_port() {
    local start_port=$1
    local end_port=$2
    for port in $(seq $start_port $end_port); do
        if ! is_port_in_use $port; then
            echo $port
            return 0
        fi
    done
    return 1
}

code_server_setup() {
    echo -e "${BLUE}Setting up code-server...${NC}"
    
    CODE_SERVER_PORT_START="${CODE_SERVER_PORT_START:-8080}"
    CODE_SERVER_PORT_END="${CODE_SERVER_PORT_END:-8100}"

    echo -e "${BLUE}Checking for available ports in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}...${NC}"
    CODE_SERVER_PORT=$(find_available_port $CODE_SERVER_PORT_START $CODE_SERVER_PORT_END)

    if [ $? -ne 0 ] || [ -z "$CODE_SERVER_PORT" ]; then
        echo -e "${RED}❌ No available ports found in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Found available port: $CODE_SERVER_PORT${NC}"

    if ! echo "$CODE_SERVER_PORT" > "/tmp/code-server-port-$USER.tmp"; then
        echo -e "${RED}❌ Failed to write port number to temporary file${NC}"
        exit 1
    fi

    mkdir -p "/home/$USER/.config/code-server"
    rm -f "/home/$USER/.config/code-server/config.yaml"
    cat <<EOF > "/home/$USER/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: none
cert: false
EOF
    chown "$USER:$USER" "/home/$USER/.config/code-server/config.yaml"
}

uv_setup() {
    echo -e "${BLUE}Setting up uv...${NC}"
    
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

nvm_setup() {
    echo -e "${BLUE}Setting up nvm...${NC}"
    
    NVM_VERSION="${NVM_VERSION:-v0.40.3}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
}

repos_setup() {
    echo -e "${BLUE}Setting up repos directory...${NC}"
    
    mkdir -p "$HOME/repos"
}

git_ssh_setup() {
    echo -e "${BLUE}Setting up Git and SSH...${NC}"
    
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"

    ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -N "" -f ~/.ssh/id_ed25519
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
}

main() {
    if [ -z "$GIT_USER_EMAIL" ]; then
        echo -e "\n${BLUE}=== Git Configuration ===${NC}"
        read -p "$(echo -e ${BLUE}Enter your git user email \(e.g., user@example.com\): ${NC})" GIT_USER_EMAIL
        echo -e "${GREEN}➜ Using git user email: ${BLUE}$GIT_USER_EMAIL${NC}\n"
    fi
    
    if [ -z "$GIT_USER_NAME" ]; then
        read -p "$(echo -e ${BLUE}Enter your git user name \(e.g., John Doe\): ${NC})" GIT_USER_NAME
        echo -e "${GREEN}➜ Using git user name: ${BLUE}$GIT_USER_NAME${NC}\n"
    fi

    echo -e "${BLUE}=== Setup (user) Configuration ===${NC}"
    echo ""

    sudo apt-get update -y || true

    code_server_setup
    uv_setup
    nvm_setup
    repos_setup
    git_ssh_setup

    echo -e "${GREEN}=== ✅ Finished Setup (user) Configuration ===${NC}" 
    echo -e "${BLUE}Code-server is configured to run on port${NC} $CODE_SERVER_PORT"
    echo -e "${BLUE}SSH public key (add this to your git hosting service):${NC}"
    cat ~/.ssh/id_ed25519.pub
}

main
