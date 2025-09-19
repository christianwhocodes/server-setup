#!/bin/bash
set -e

# ************ Input, Variables & Functions ************

export DEBIAN_FRONTEND=noninteractive

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Domain input
echo -e "\n${BLUE}=== Domain Configuration ===${NC}"
read -p "$(echo -e ${BLUE}Enter your domain name \(e.g., code.example.com\): ${NC})" DOMAIN_NAME
echo -e "${GREEN}➜ Using domain: ${BLUE}$DOMAIN_NAME${NC}\n"
export DOMAIN_NAME

SETUP_TYPE="post-user"

TMP_DIR="/tmp/foundry/$SETUP_TYPE"
mkdir -p "$TMP_DIR"

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts"

download_and_run() {
    local script="$1"
    local tmp_file="$TMP_DIR/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    sudo -E bash "$tmp_file"
}

# ***************** Run Scripts *****************

echo -e "${BLUE}=== Starting Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

# * Order of execution matters! *
download_and_run "code-server.sh"

# Cleanup
rm -rf "$TMP_DIR"

# Final message
echo -e "\n${GREEN}=== Setup Successfully Completed! ===${NC}"
echo -e "${BLUE}➜ Code Server has been configured with SSL at:${NC}"
echo -e "${GREEN}  https://$DOMAIN_NAME${NC}"
echo -e "\n${BLUE}You can now access your Code Server securely through your browser.${NC}"

# ***************** End *****************