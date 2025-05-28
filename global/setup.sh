#!/bin/bash
set -e

# ################# Variables and Functions ################# 

export DEBIAN_FRONTEND=noninteractive

SETUP_TYPE="global"

TMP_DIR="/tmp/server-setup/$SETUP_TYPE"
mkdir -p "$TMP_DIR"

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/server-setup/main/$SETUP_TYPE/scripts"

download_and_run() {
    local script="$1"
    local tmp_file="$TMP_DIR/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    sudo bash "$tmp_file"
}

# ################# Start of the script #################

echo "=== Start Setup ($SETUP_TYPE) Configuration ==="
echo ""

# Set up code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Set up nginx
download_and_run "nginx.sh"

# Set up certbot for SSL certificates
download_and_run "certbot.sh"

# Set up PostgreSQL
download_and_run "postgres.sh"

# Set up Necessary packages
download_and_run "necessary-packages.sh"

# Cleanup
rm -rf "$TMP_DIR"

# Final message
echo "=== ✅ Finished Setup ($SETUP_TYPE) Configuration ==="

# ################# End of the script #################