#!/bin/bash
set -e

# ************ Input, Variables & Functions ************

export DEBIAN_FRONTEND=noninteractive

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SETUP_TYPE="system"

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

echo -e "${BLUE}=== Start Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

# * Order of execution matters! * 
download_and_run "nginx.sh"
download_and_run "certbot.sh"
download_and_run "code-server.sh"
download_and_run "postgres.sh"
download_and_run "necessary-packages.sh"

# Cleanup
rm -rf "$TMP_DIR"

# Final message
echo -e "${GREEN}=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===${NC}"

# ***************** End *****************