#!/bin/bash
# PostgreSQL setup script
# This script is idempotent and safe to run multiple times

set -e
export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

postgres_setup() {
  echo -e "${BLUE}Setting up PostgreSQL...${NC}"

  # Check if PostgreSQL is already installed
  if command -v psql >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL already installed${NC}"
  else
    if ! apt install -y postgresql postgresql-contrib libpq-dev; then
      echo -e "${RED}❌ Failed to install PostgreSQL${NC}"
      exit 1
    fi
  fi

  if ! systemctl is-enabled --quiet postgresql 2>/dev/null; then
    if ! systemctl enable postgresql; then
      echo -e "${RED}❌ Failed to enable PostgreSQL${NC}"
      exit 1
    fi
  fi

  if ! systemctl is-active --quiet postgresql; then
    if ! systemctl start postgresql; then
      echo -e "${RED}❌ Failed to start PostgreSQL${NC}"
      exit 1
    fi
  fi

  echo -e "${GREEN}✅ PostgreSQL is running${NC}"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  postgres_setup
fi
