#!/bin/bash
# OpenSSH and UFW setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

openssh_setup() {
  echo -e "${BLUE}Setting up OpenSSH and UFW...${NC}"

  if ! command -v ufw >/dev/null 2>&1; then
    if ! apt-get install -y ufw; then
      echo -e "${RED}⚠️  Warning: Failed to install ufw${NC}"
      return 0
    fi
  fi

  if command -v ufw >/dev/null 2>&1; then
    # Check if OpenSSH rule already exists
    if ! ufw status | grep -q "OpenSSH.*ALLOW"; then
      echo -e "${YELLOW}Adding OpenSSH rule to UFW...${NC}"
      if ! ufw allow OpenSSH; then
        echo -e "${RED}⚠️  Warning: Failed to allow OpenSSH in ufw${NC}"
        return 0
      fi
    else
      echo -e "${GREEN}✅ OpenSSH rule already exists in UFW${NC}"
    fi
    
    # Verify the rule was actually added before enabling
    if ufw status | grep -q "OpenSSH.*ALLOW"; then
      if ufw status | grep -q "Status: inactive"; then
        echo -e "${YELLOW}Enabling UFW firewall...${NC}"
        if ! ufw --force enable; then
          echo -e "${RED}⚠️  Warning: Failed to enable ufw${NC}"
          return 0
        fi
        echo -e "${GREEN}✅ UFW enabled successfully${NC}"
      else
        echo -e "${GREEN}✅ UFW already enabled${NC}"
      fi
    else
      echo -e "${RED}❌ Error: OpenSSH rule not confirmed in UFW, skipping enable${NC}"
      echo -e "${RED}   This is a safety measure to prevent lockout${NC}"
      return 1
    fi
  fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  openssh_setup
fi
