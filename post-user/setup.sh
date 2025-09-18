#!/bin/bash
set -e

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ***************** Other Variables and Functions ***************** 
SETUP_TYPE="post-user" 
export DEBIAN_FRONTEND=noninteractive
TMP_DIR="/tmp/foundry/$SETUP_TYPE"
mkdir -p "$TMP_DIR"
BASE_URL="https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts"

# Add domain input
echo -e "\n${BLUE}=== Domain Configuration ===${NC}"
read -p "$(echo -e ${BLUE}Enter your domain name \(e.g., code.example.com\): ${NC})" DOMAIN_NAME
echo -e "${GREEN}➜ Using domain: ${BLUE}$DOMAIN_NAME${NC}\n"
export DOMAIN_NAME

download_and_run() {
    local script="$1"
    local tmp_file="$TMP_DIR/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    sudo bash "$tmp_file" "$DOMAIN_NAME"
}

# ***************** Start of the script *****************
echo -e "${BLUE}=== Starting Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

download_and_run "code-server.sh"

# Cleanup
rm -rf "$TMP_DIR"

# Final message
echo -e "\n${GREEN}=== Setup Successfully Completed! ===${NC}"
echo -e "${BLUE}➜ Code Server has been configured with SSL at:${NC}"
echo -e "${GREEN}  https://$DOMAIN_NAME${NC}"
echo -e "\n${BLUE}You can now access your Code Server securely through your browser.${NC}"
# ***************** End of the script *****************