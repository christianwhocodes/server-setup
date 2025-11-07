#!/bin/bash
# Repos directory setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

repos_setup() {
  echo -e "${BLUE}Setting up repos directory...${NC}"

  if [ -d "$HOME/repos" ]; then
    echo -e "${GREEN}✅ repos directory already exists${NC}"
  else
    mkdir -p "$HOME/repos"
    echo -e "${GREEN}✅ Created repos directory${NC}"
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  repos_setup
fi
