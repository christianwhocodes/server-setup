#!/bin/bash
# Code-server installation script (system-wide install only)
# This script is idempotent and safe to run multiple times
# Must be run with sudo privileges

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

code_server_install() {
  echo -e "${BLUE}Installing code-server system-wide...${NC}"

  # Check if code-server is already installed
  if command -v code-server >/dev/null 2>&1; then
    echo -e "${GREEN}✅ code-server already installed${NC}"
    return 0
  fi

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
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  code_server_install
fi
