#!/bin/bash
set -e

# ################# Variables and Functions ################# 

export DEBIAN_FRONTEND=noninteractive

SETUP_TYPE="user"

TMP_DIR="/tmp/server-setup/$SETUP_TYPE"
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
download_and_run "github.sh"

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
echo ""
echo ""
echo "Restart shell by running the alias 'refresh' or opening a new terminal."
echo ""
echo ""
echo "############## Node Js Configuration ##############"
echo "To install node and npm run 'nvm install node' or 'nvm install <version>'";
echo "You may want to start by installing some global packages like 'npm install -g npm@latest serve pm2'";
echo ""
echo ""
echo "############## Python Configuration ##############"
echo "To install python run 'pyenv install <version>' or 'pyenv global <version>'";
echo "You may want to start by installing some global packages like 'pip install --upgrade pip poetry jupyter'";
echo ""
echo ""
echo "############## Code Server ##############"
echo "Request system admin to enable the code-server service for you.";
echo "The system admin can run the following command: 'sudo systemctl enable --now code-server@$USER'";
echo "The system admin can then configure NGINX to reverse proxy to code-server under a domain e.g 'https://developer.example.com/$USER'";
echo "You can then access code-server at that domain.";

# ################# End of the script #################