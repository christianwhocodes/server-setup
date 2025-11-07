#!/bin/bash
# Code-server service management script
# This script is idempotent and safe to run multiple times
# Must be run with sudo privileges

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Required environment variable
TARGET_USER="${TARGET_USER:?TARGET_USER environment variable is required}"

code_server_service_enable() {
  echo -e "${BLUE}Enabling code-server service for user: $TARGET_USER${NC}"
  
  # Verify target user exists
  if ! id "$TARGET_USER" &>/dev/null; then
    echo -e "${RED}❌ Target user $TARGET_USER does not exist${NC}"
    exit 1
  fi

  # Wait a moment for systemd to recognize the service
  sleep 2
  
  # Check if service file exists
  if [[ ! -f "/lib/systemd/system/code-server@.service" ]] && [[ ! -f "/usr/lib/systemd/system/code-server@.service" ]]; then
    echo -e "${YELLOW}⚠️  Service file not found. Cannot enable service automatically.${NC}"
    echo -e "${YELLOW}   Run manually: sudo systemctl enable --now code-server@$TARGET_USER${NC}"
    exit 1
  fi

  # Check if service is already enabled
  if systemctl is-enabled --quiet "code-server@$TARGET_USER" 2>/dev/null; then
    echo -e "${GREEN}✅ code-server service already enabled for $TARGET_USER${NC}"
  else
    # Enable the service
    if systemctl enable "code-server@$TARGET_USER" 2>/dev/null; then
      echo -e "${GREEN}✅ code-server service enabled for $TARGET_USER${NC}"
    else
      echo -e "${YELLOW}⚠️  Could not enable code-server service${NC}"
      echo -e "${YELLOW}   Run manually: sudo systemctl enable code-server@$TARGET_USER${NC}"
      exit 1
    fi
  fi

  # Check if service is already running
  if systemctl is-active --quiet "code-server@$TARGET_USER" 2>/dev/null; then
    echo -e "${GREEN}✅ code-server service already running for $TARGET_USER${NC}"
  else
    # Start the service
    if systemctl start "code-server@$TARGET_USER" 2>/dev/null; then
      echo -e "${GREEN}✅ code-server service started for $TARGET_USER${NC}"
    else
      echo -e "${YELLOW}⚠️  Could not start code-server service${NC}"
      echo -e "${YELLOW}   Run manually: sudo systemctl start code-server@$TARGET_USER${NC}"
      exit 1
    fi
  fi

  echo -e "${GREEN}✅ code-server service setup completed for $TARGET_USER${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  code_server_service_enable
fi
