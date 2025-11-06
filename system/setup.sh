#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SETUP_TYPE="system"

TMP_DIR="/tmp/foundry/$SETUP_TYPE"
mkdir -p "$TMP_DIR"

REPO_OWNER="${REPO_OWNER:-christianwhocodes}"
REPO_NAME="${REPO_NAME:-foundry}"
REPO_BRANCH="${REPO_BRANCH:-main}"

BASE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}/$SETUP_TYPE/scripts"

download_and_run() {
    local script="$1"
    local tmp_file="$TMP_DIR/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    sudo -E bash "$tmp_file"
}

echo -e "${BLUE}=== Start Setup ($SETUP_TYPE) Configuration ===${NC}"
echo ""

sudo apt-get update -y || true

download_and_run "openssh.sh"
download_and_run "necessary-packages.sh"
download_and_run "nginx.sh"
download_and_run "certbot.sh"
download_and_run "code-server.sh"
download_and_run "postgres.sh"

rm -rf "$TMP_DIR"

echo -e "${GREEN}=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===${NC}"
