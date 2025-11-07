#!/bin/bash
# uv Python package manager setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

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

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  uv_setup
fi
