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
  tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 24
}

code_server_setup() {
  echo -e "${BLUE}Setting up code-server...${NC}"

  CODE_SERVER_PORT_START="${CODE_SERVER_PORT_START:-8080}"
  CODE_SERVER_PORT_END="${CODE_SERVER_PORT_END:-8100}"

  validate_port_range "$CODE_SERVER_PORT_START" "$CODE_SERVER_PORT_END"

  # Check if config already exists
  if [ -f "$HOME/.config/code-server/config.yaml" ]; then
    EXISTING_PORT=$(grep "bind-addr:" "$HOME/.config/code-server/config.yaml" | awk -F: '{print $NF}' | tr -d ' ')
    
    # Check if existing port is still available
    if [ -n "$EXISTING_PORT" ] && ! is_port_in_use "$EXISTING_PORT"; then
      echo -e "${GREEN}✅ Using existing code-server config on port $EXISTING_PORT${NC}"
      CODE_SERVER_PORT="$EXISTING_PORT"
      CODE_SERVER_PASSWORD=$(grep "password:" "$HOME/.config/code-server/config.yaml" | awk -F: '{print $2}' | tr -d ' ')
      return 0
    fi
  fi

  echo -e "${BLUE}Checking for available ports in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}...${NC}"
  CODE_SERVER_PORT=$(find_available_port $CODE_SERVER_PORT_START $CODE_SERVER_PORT_END)

  if [ $? -ne 0 ] || [ -z "$CODE_SERVER_PORT" ]; then
    echo -e "${RED}❌ No available ports found in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}${NC}"
    exit 1
  fi

  echo -e "${GREEN}✅ Found available port: $CODE_SERVER_PORT${NC}"

  CODE_SERVER_PASSWORD=$(generate_random_password)

  mkdir -p "$HOME/.config/code-server"
  cat <<EOF >"$HOME/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF
  chmod 600 "$HOME/.config/code-server/config.yaml"
}

uv_setup() {
  echo -e "${BLUE}Setting up uv...${NC}"

  # Check if uv is already installed
  UV_BIN="$HOME/.local/bin/uv"
  if [ -f "$UV_BIN" ]; then
    echo -e "${GREEN}✅ uv already installed${NC}"
  else
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
      echo -e "${RED}❌ Failed to install uv${NC}"
      exit 1
    fi
  fi

  # Try to install latest Python using uv's binary path directly
  if [ -f "$UV_BIN" ]; then
    # Check if Python is already installed via uv
    if "$UV_BIN" python list 2>/dev/null | grep -q "cpython"; then
      echo -e "${GREEN}✅ Python already installed with uv${NC}"
    else
      if ! "$UV_BIN" python install; then
        echo -e "${BLUE}ℹ️  You can install Python manually after restarting your shell with: uv python install${NC}"
      else
        echo -e "${GREEN}✅ Python installed successfully with uv${NC}"
      fi
    fi
  else
    echo -e "${BLUE}ℹ️  You can install Python manually after restarting your shell with: uv python install${NC}"
  fi
}

nvm_setup() {
  echo -e "${BLUE}Setting up nvm...${NC}"

  NVM_VERSION="${NVM_VERSION:-v0.40.3}"
  
  # Check if nvm is already installed
  export NVM_DIR="$HOME/.nvm"
  if [ -d "$NVM_DIR" ]; then
    echo -e "${GREEN}✅ nvm already installed${NC}"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  else
    if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash; then
      echo -e "${RED}❌ Failed to install nvm${NC}"
      exit 1
    fi
    # Source nvm immediately to make it available in this session
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi

  if command -v nvm >/dev/null 2>&1; then
    # Check if Node.js is already installed
    if nvm ls | grep -q "node"; then
      echo -e "${GREEN}✅ Node.js already installed with nvm${NC}"
    else
      if ! nvm install node; then
        echo -e "${BLUE}ℹ️  You can install Node.js manually after restarting your shell with: nvm install node${NC}"
      else
        echo -e "${GREEN}✅ Node.js installed successfully with nvm${NC}"

        if npm install -g npm@latest; then
          echo -e "${GREEN}✅ npm updated successfully${NC}"
        fi
      fi
    fi
  else
    echo -e "${BLUE}ℹ️  You can install Node.js manually after restarting your shell with: nvm install node${NC}"
  fi
}

repos_setup() {
  echo -e "${BLUE}Setting up repos directory...${NC}"

  if [ -d "$HOME/repos" ]; then
    echo -e "${GREEN}✅ repos directory already exists${NC}"
  else
    mkdir -p "$HOME/repos"
    echo -e "${GREEN}✅ Created repos directory${NC}"
  fi
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

  # Configure git (safe to run multiple times)
  git config --global user.name "$GIT_USER_NAME"
  git config --global user.email "$GIT_USER_EMAIL"

  mkdir -p ~/.ssh
  chmod 700 ~/.ssh

  # Check if SSH key already exists
  if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${GREEN}✅ SSH key already exists${NC}"
  else
    ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -N "" -f ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    echo -e "${GREEN}✅ Generated new SSH key${NC}"
  fi

  # Create SSH config if it doesn't exist
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
