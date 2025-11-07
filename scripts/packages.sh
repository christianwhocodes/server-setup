#!/bin/bash
# Development packages setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

packages_setup() {
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
  
  echo -e "${GREEN}✅ All packages installed successfully${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  packages_setup
fi
