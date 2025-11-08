#!/bin/bash
# Code-server user configuration script
# This script is idempotent and safe to run multiple times
# Must be run as the target user (not sudo)

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required environment variables
CODE_SERVER_PORT_START="${CODE_SERVER_PORT_START:?CODE_SERVER_PORT_START environment variable is required}"
CODE_SERVER_PORT_END="${CODE_SERVER_PORT_END:?CODE_SERVER_PORT_END environment variable is required}"

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

code_server_configure() {
  echo -e "${BLUE}Configuring code-server for user: $USER${NC}"
  
  validate_port_range "$CODE_SERVER_PORT_START" "$CODE_SERVER_PORT_END"

  CONFIG_DIR="$HOME/.config/code-server"
  CONFIG_FILE="$CONFIG_DIR/config.yaml"
  
  # Check if config already exists
  if [ -f "$CONFIG_FILE" ]; then
    # Get existing port
    EXISTING_PORT=$(grep "bind-addr:" "$CONFIG_FILE" | awk -F: '{print $NF}' | tr -d ' ')
    
    # Check if existing port is in use by another service
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
      chmod 700 "$CONFIG_DIR"
      chmod 600 "$CONFIG_FILE"
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
    chmod 700 "$CONFIG_DIR"
    chmod 600 "$CONFIG_FILE"
    echo -e "${GREEN}✅ code-server configuration created${NC}"
  fi

  echo -e "${GREEN}✅ code-server configuration completed for $USER${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  code_server_configure
fi
