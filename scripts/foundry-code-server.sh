#!/bin/bash
# Code-server setup script (system install + user config + service enable)
# This script is idempotent and safe to run multiple times
# Must be run as sudo user, but configures for TARGET_USER

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required environment variables
TARGET_USER="${TARGET_USER:?TARGET_USER environment variable is required}"
CODE_SERVER_PORT_START="${CODE_SERVER_PORT_START:-8080}"
CODE_SERVER_PORT_END="${CODE_SERVER_PORT_END:-8100}"

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
  echo -e "${BLUE}Setting up code-server for user: $TARGET_USER${NC}"
  
  validate_port_range "$CODE_SERVER_PORT_START" "$CODE_SERVER_PORT_END"

  # Get target user's home directory
  TARGET_USER_HOME=$(eval echo ~$TARGET_USER)
  
  if [ ! -d "$TARGET_USER_HOME" ]; then
    echo -e "${RED}❌ Target user home directory not found: $TARGET_USER_HOME${NC}"
    exit 1
  fi

  # Step 1: Install code-server system-wide (if not already installed)
  echo -e "${BLUE}Step 1: Installing code-server system-wide...${NC}"
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

  # Step 2: Configure code-server for target user
  echo -e "${BLUE}Step 2: Configuring code-server for $TARGET_USER...${NC}"
  
  CONFIG_DIR="$TARGET_USER_HOME/.config/code-server"
  CONFIG_FILE="$CONFIG_DIR/config.yaml"
  
  # Check if config already exists
  if [ -f "$CONFIG_FILE" ]; then
    # Get existing port
    EXISTING_PORT=$(grep "bind-addr:" "$CONFIG_FILE" | awk -F: '{print $NF}' | tr -d ' ')
    
    # Check if existing port is in use
    if [ -n "$EXISTING_PORT" ] && ! is_port_in_use "$EXISTING_PORT"; then
      echo -e "${GREEN}✅ Using existing code-server config on port $EXISTING_PORT${NC}"
      CODE_SERVER_PORT="$EXISTING_PORT"
    else
      # Need to find a new port
      echo -e "${YELLOW}Existing port is in use, finding new port...${NC}"
      CODE_SERVER_PORT=$(find_available_port $CODE_SERVER_PORT_START $CODE_SERVER_PORT_END)
      
      if [ $? -ne 0 ] || [ -z "$CODE_SERVER_PORT" ]; then
        echo -e "${RED}❌ No available ports found in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}${NC}"
        exit 1
      fi
      
      echo -e "${GREEN}✅ Found available port: $CODE_SERVER_PORT${NC}"
      
      # Generate new password and update config
      CODE_SERVER_PASSWORD=$(generate_random_password)
      
      mkdir -p "$CONFIG_DIR"
      cat <<EOF >"$CONFIG_FILE"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF
      echo -e "${GREEN}✅ code-server configuration updated${NC}"
    fi
  else
    # No existing config, create new one
    echo -e "${BLUE}Checking for available ports in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}...${NC}"
    CODE_SERVER_PORT=$(find_available_port $CODE_SERVER_PORT_START $CODE_SERVER_PORT_END)

    if [ $? -ne 0 ] || [ -z "$CODE_SERVER_PORT" ]; then
      echo -e "${RED}❌ No available ports found in range ${CODE_SERVER_PORT_START}-${CODE_SERVER_PORT_END}${NC}"
      exit 1
    fi

    echo -e "${GREEN}✅ Found available port: $CODE_SERVER_PORT${NC}"

    CODE_SERVER_PASSWORD=$(generate_random_password)

    mkdir -p "$CONFIG_DIR"
    cat <<EOF >"$CONFIG_FILE"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $CODE_SERVER_PASSWORD
cert: false
EOF
    echo -e "${GREEN}✅ code-server configuration created${NC}"
  fi

  # Step 3: Set proper permissions (sudo user owns, target user can only read)
  echo -e "${BLUE}Step 3: Setting permissions...${NC}"
  
  # Make config directory readable by target user but owned by sudo user
  chown -R root:root "$CONFIG_DIR"
  chmod 755 "$CONFIG_DIR"
  chmod 600 "$CONFIG_FILE"
  
  echo -e "${GREEN}✅ Permissions set (sudo user owns, target user can read)${NC}"

  # Step 4: Enable and start code-server service for target user
  echo -e "${BLUE}Step 4: Enabling code-server service for $TARGET_USER...${NC}"
  
  # Wait a moment for systemd to recognize the service
  sleep 2
  
  # Check if service file exists
  if [[ ! -f "/lib/systemd/system/code-server@.service" ]] && [[ ! -f "/usr/lib/systemd/system/code-server@.service" ]]; then
    echo -e "${YELLOW}⚠️  Service file not found. Cannot enable service automatically.${NC}"
    echo -e "${YELLOW}   Run manually: sudo systemctl enable --now code-server@$TARGET_USER${NC}"
  else
    # Enable and start the service
    if systemctl enable --now "code-server@$TARGET_USER" 2>/dev/null; then
      echo -e "${GREEN}✅ code-server service enabled and started for $TARGET_USER${NC}"
    else
      echo -e "${YELLOW}⚠️  Could not enable code-server service${NC}"
      echo -e "${YELLOW}   Run manually: sudo systemctl enable --now code-server@$TARGET_USER${NC}"
    fi
  fi

  echo -e "${GREEN}✅ code-server setup completed for $TARGET_USER${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  code_server_setup
fi
