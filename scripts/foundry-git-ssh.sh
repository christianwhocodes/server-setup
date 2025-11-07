#!/bin/bash
# Git and SSH setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required environment variables
GIT_USER_NAME="${GIT_USER_NAME:?GIT_USER_NAME environment variable is required}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:?GIT_USER_EMAIL environment variable is required}"

validate_email() {
  local email=$1
  if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo -e "${RED}❌ Invalid email format: $email${NC}"
    exit 1
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
  echo -e "${GREEN}✅ Git configured with name: $GIT_USER_NAME${NC}"
  echo -e "${GREEN}✅ Git configured with email: $GIT_USER_EMAIL${NC}"

  mkdir -p ~/.ssh
  chmod 700 ~/.ssh

  # Check if SSH key already exists
  if [ -f ~/.ssh/id_ed25519 ]; then
    echo -e "${GREEN}✅ SSH key already exists${NC}"
  else
    echo -e "${YELLOW}Generating new SSH key...${NC}"
    ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL" -N "" -f ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub
    echo -e "${GREEN}✅ Generated new SSH key${NC}"
  fi

  # Create SSH config if it doesn't exist
  if [ ! -f ~/.ssh/config ]; then
    touch ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo -e "${GREEN}✅ Created SSH config file${NC}"
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  git_ssh_setup
fi
