#!/bin/bash 
set -e 

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ***************** Other Variables and Functions ***************** 
SETUP_TYPE="user" 
export DEBIAN_FRONTEND=noninteractive 
export TMP_DIR="/home/$USER/foundry/$SETUP_TYPE" 
mkdir -p "$TMP_DIR" 
BASE_URL="https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts" 
 
download_and_run() { 
    local script="$1" 
    local tmp_file="$TMP_DIR/$script" 
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file" 
    chmod +x "$tmp_file" 
    bash "$tmp_file" 
} 

# ***************** Start of the script *****************
echo -e "${BLUE}=== Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

download_and_run "code-server.sh"
CODE_SERVER_PORT=$(cat "$TMP_DIR/code-server-port.tmp")
CODE_SERVER_PASS=$(cat "$TMP_DIR/code-server-pass.tmp")

download_and_run "uv.sh" 
download_and_run "nvm.sh"  
download_and_run "repos.sh" 
download_and_run "bash-aliases.sh" 
 
# Cleanup 
rm -rf "$TMP_DIR" 
 
# Final message 
echo -e "${GREEN}=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===${NC}" 
echo -e "${BLUE}Code-server is configured to run on port${NC} $CODE_SERVER_PORT"
echo -e "${BLUE}Code-server password in ~/.config/code-server/config.yaml:${NC} $CODE_SERVER_PASS"
# ***************** End of the script *****************
