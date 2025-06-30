#!/bin/bash
set -e

# ################# Variables and Functions ################# 

export DEBIAN_FRONTEND=noninteractive

SETUP_TYPE="user"

TMP_DIR="/home/$USER/server-setup/$SETUP_TYPE"
mkdir -p "$TMP_DIR"

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/server-setup/main/$SETUP_TYPE/scripts"

download_and_run() {
    local script="$1"
    local tmp_file="$TMP_DIR/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    bash "$tmp_file"
}

# ################# Start of the script #################

echo "=== Setup ($SETUP_TYPE) Configuration ==="
echo ""

# Code Server port prompt
read -p "Enter port for code-server (default: 8080): " CODE_SERVER_PORT
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
export CODE_SERVER_PORT

if ! [[ "$CODE_SERVER_PORT" =~ ^[0-9]+$ ]] || [ "$CODE_SERVER_PORT" -lt 1024 ] || [ "$CODE_SERVER_PORT" -gt 65535 ]; then
  echo "Port must be between 1024 and 65535"
  exit 1
fi

# Display confirmation
echo ""
echo "- Code-server port: $CODE_SERVER_PORT"
echo ""
read -p "Proceed with setup? (y/N): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0

# Set up github folder
# download_and_run "github.sh"

# Set up code-server
download_and_run "code-server.sh"

# Set up nvm
download_and_run "nvm.sh"

# Set up Pyenv
download_and_run "pyenv.sh"

# Set up bash aliases
download_and_run "bash-aliases.sh"

# Cleanup
rm -rf "$TMP_DIR"

# Final message
echo "=== ✅ Finished Setup ($SETUP_TYPE) Configuration ==="

# ################# End of the script #################
