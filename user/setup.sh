#!/bin/bash 
set -e 

# ************ Input, Variables & Functions ************

export DEBIAN_FRONTEND=noninteractive 

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Git user email input
echo -e "\n${BLUE}=== Git Configuration ===${NC}"
read -p "$(echo -e ${BLUE}Enter your git user email \(e.g., user@example.com\): ${NC})" GIT_USER_EMAIL
echo -e "${GREEN}➜ Using git user email: ${BLUE}$GIT_USER_EMAIL${NC}\n"
export GIT_USER_EMAIL

# Git user name input
read -p "$(echo -e ${BLUE}Enter your git user name \(e.g., John Doe\): ${NC})" GIT_USER_NAME
echo -e "${GREEN}➜ Using git user name: ${BLUE}$GIT_USER_NAME${NC}\n"
export GIT_USER_NAME

SETUP_TYPE="user" 

export TMP_DIR="/home/$USER/foundry/$SETUP_TYPE" 
mkdir -p "$TMP_DIR" 

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts" 
 
download_and_run() { 
    local script="$1" 
    local tmp_file="$TMP_DIR/$script" 
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file" 
    chmod +x "$tmp_file" 
    bash -E "$tmp_file" 
} 

# ***************** Run Scripts *****************

echo -e "${BLUE}=== Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

# * Order of execution matters! *
download_and_run "code-server.sh"
CODE_SERVER_PORT=$(cat "$TMP_DIR/code-server-port.tmp")
CODE_SERVER_PASS=$(cat "$TMP_DIR/code-server-pass.tmp")

download_and_run "uv.sh" 
download_and_run "nvm.sh"  
download_and_run "repos.sh" 
download_and_run "bash-aliases.sh"
download_and_run "git-ssh.sh" 
 
# Cleanup 
rm -rf "$TMP_DIR" 
 
# Final message 
echo -e "${GREEN}=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===${NC}" 
echo -e "${BLUE}Code-server is configured to run on port${NC} $CODE_SERVER_PORT"
echo -e "${BLUE}Code-server password in ~/.config/code-server/config.yaml:${NC} $CODE_SERVER_PASS".
echo -e "${BLUE}SSH public key (add this to your git hosting service):${NC}"
cat ~/.ssh/id_ed25519.pub

# ***************** End *****************