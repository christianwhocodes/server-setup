#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/server-setup/main/scripts"

download_and_source() {
    source <(curl -fsSL "$BASE_URL/$1")
}

download_and_run() {
    curl -fsSL "$BASE_URL/$1" | bash
}

# Interactive config and export vars
echo "=== Server Setup Configuration ==="
echo ""

# username prompt
read -p "Enter the username to create: " USERNAME
if [ -z "$USERNAME" ]; then
  echo "Username cannot be empty"
  exit 1
fi

# password prompt
echo "Enter password for user '$USERNAME':"
read -s PASSWORD
if [ -z "$PASSWORD" ]; then
  echo "Password cannot be empty"
  exit 1
fi

# confirm password prompt
echo "Confirm password for user '$USERNAME':"
read -s PASSWORD_CONFIRM
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match"
  exit 1
fi

# code-server port prompt
read -p "Enter port for code-server (default: 8080): " CODE_SERVER_PORT
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}

if ! [[ "$CODE_SERVER_PORT" =~ ^[0-9]+$ ]] || [ "$CODE_SERVER_PORT" -lt 1024 ] || [ "$CODE_SERVER_PORT" -gt 65535 ]; then
  echo "Port must be between 1024 and 65535"
  exit 1
fi

# Display summary and confirm
echo ""
echo "Summary:"
echo "- Username: $USERNAME"
echo "- Code-server port: $CODE_SERVER_PORT"
echo ""
read -p "Proceed with setup? (y/N): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0

# Setup logging
LOG_FILE="/var/log/server-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "${LOG_FILE}") 2>&1

# Export variables for use in scripts
export USERNAME PASSWORD CODE_SERVER_PORT

# Run setup modules
download_and_run "user-setup.sh"
download_and_run "install-packages.sh"
download_and_run "code-server.sh"
download_and_run "postgres.sh"
download_and_run "nginx.sh"
download_and_run "certbot.sh"
download_and_run "bash-aliases.sh"
download_and_run "nvm.sh"
download_and_run "pyenv.sh"

# Finalize setup
echo "✅ Server setup complete at $(date)"
echo "Setup log can be found at ${LOG_FILE}"
echo "To apply some changes, restart shell by running 'source ~/.bashrc' or 'exec "$SHELL"' or opening a new terminal."

# End of script