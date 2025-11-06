#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

validate_email() {
    local email=$1
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}❌ Invalid email format: $email${NC}"
        exit 1
    fi
}

validate_port_range() {
    local start=$1
    local end=$2
    if [ "$start" -ge "$end" ]; then
        echo -e "${RED}❌ CODE_SERVER_PORT_START ($start) must be less than CODE_SERVER_PORT_END ($end)${NC}"
        exit 1
    fi
}

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

generate_random_password() {
    tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c 24
}

code_server_setup() {
    echo -e "${BLUE}Setting up code-server...${NC}"

    CODE_SERVER_PORT_START="${CODE_SERVER_PORT_START:-8080}"
    CODE_SERVER_PORT_END="${CODE_SERVER_PORT_END:-8100}"

    validate_port_range "$CODE_SERVER_PORT_START" "$CODE_SERVER_PORT_END"

    echo -e "${BLUE}Checking for available ports in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}...${NC}"
    CODE_SERVER_PORT=$(find_available_port $CODE_SERVER_PORT_START $CODE_SERVER_PORT_END)

    if [ $? -ne 0 ] || [ -z "$CODE_SERVER_PORT" ]; then
        echo -e "${RED}❌ No available ports found in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Found available port: $CODE_SERVER_PORT${NC}"

    CODE_SERVER_PASSWORD=$(generate_random_password)

    mkdir -p "$HOME/.config/code-server"
    rm -f "$HOME/.config/code-server/config.yaml"
    cat <<EOF > "$HOME/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF
    chmod 600 "$HOME/.config/code-server/config.yaml"
}

uv_setup() {
    echo -e "${BLUE}Setting up uv...${NC}"

    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        echo -e "${RED}❌ Failed to install uv${NC}"
        exit 1
    fi
}

nvm_setup() {
    echo -e "${BLUE}Setting up nvm...${NC}"

    NVM_VERSION="${NVM_VERSION:-v0.40.3}"
    if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash; then
        echo -e "${RED}❌ Failed to install nvm${NC}"
        exit 1
    fi

    # Source nvm immediately to make it available in this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo -e "${GREEN}✅ nvm is now available in this session${NC}"
}

repos_setup() {
    echo -e "${BLUE}Setting up repos directory...${NC}"

    mkdir -p "$HOME/repos"
}

git_ssh_setup() {
    echo -e "${BLUE}Setting up Git and SSH...${NC}"

    validate_email "$GIT_USER_EMAIL"

    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}❌ git command not found${NC}"
        exit 1
    fi

    if ! command -v ssh-keygen >/dev/null 2>&1; then
        echo -e "${RED}❌ ssh-keygen command not found${NC}"
        exit 1
    fi

    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -N "" -f ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub

    # Create SSH config for better key management
    if [ ! -f ~/.ssh/config ]; then
        touch ~/.ssh/config
        chmod 600 ~/.ssh/config
    fi
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

    code_server_setup
    uv_setup
    nvm_setup
    repos_setup
    git_ssh_setup

    echo -e "${GREEN}=== ✅ Finished Setup (user) Configuration ===${NC}"
    echo -e "${BLUE}Code-server is configured to run on port${NC} $CODE_SERVER_PORT"
    echo -e "${BLUE}Code-server password:${NC} $CODE_SERVER_PASSWORD"
    echo -e "${BLUE}SSH public key (add this to your git hosting service):${NC}"
    cat ~/.ssh/id_ed25519.pub
}

main
