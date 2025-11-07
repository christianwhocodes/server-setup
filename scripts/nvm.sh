#!/bin/bash
# nvm Node.js version manager setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

  # Check if nvm is available as a shell function
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Source nvm to ensure it's loaded
    \. "$NVM_DIR/nvm.sh"
    
    # Check if nvm function exists
    if declare -f nvm >/dev/null 2>&1; then
      # Check if Node.js is already installed
      if nvm ls 2>/dev/null | grep -q "node"; then
        echo -e "${GREEN}✅ Node.js already installed with nvm${NC}"
      else
        echo -e "${YELLOW}Installing Node.js with nvm...${NC}"
        if ! nvm install node; then
          echo -e "${YELLOW}⚠️  Failed to install Node.js in this session${NC}"
          echo -e "${BLUE}ℹ️  You can install Node.js manually after restarting your shell with: nvm install node${NC}"
        else
          echo -e "${GREEN}✅ Node.js installed successfully with nvm${NC}"

          if npm install -g npm@latest; then
            echo -e "${GREEN}✅ npm updated successfully${NC}"
          fi
        fi
      fi
    else
      echo -e "${YELLOW}⚠️  nvm function not available in current session${NC}"
      echo -e "${BLUE}ℹ️  You can install Node.js manually after restarting your shell with: nvm install node${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  nvm.sh not found${NC}"
    echo -e "${BLUE}ℹ️  You can install Node.js manually after restarting your shell with: nvm install node${NC}"
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  nvm_setup
fi
