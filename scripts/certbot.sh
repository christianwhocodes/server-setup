#!/bin/bash
# Certbot setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

certbot_setup() {
  echo -e "${BLUE}Setting up Certbot...${NC}"

  if ! command -v snap >/dev/null 2>&1; then
    echo -e "${RED}❌ snapd is not installed${NC}"
    exit 1
  fi

  # Check if certbot is already installed via snap
  if snap list certbot >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Certbot already installed${NC}"
    return 0
  fi

  if ! snap install core; then
    echo -e "${RED}❌ Failed to install snap core${NC}"
    exit 1
  fi

  snap refresh core

  # Remove apt version if it exists
  apt remove -y certbot 2>/dev/null || true

  if ! snap install --classic certbot; then
    echo -e "${RED}❌ Failed to install certbot${NC}"
    exit 1
  fi

  ln -sf /snap/bin/certbot /usr/bin/certbot
  
  echo -e "${GREEN}✅ Certbot installed successfully${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  certbot_setup
fi
