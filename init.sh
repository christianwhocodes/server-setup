#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/server-setup/main/scripts"

# Interactive config and export vars
echo "=== Server Setup Configuration ==="
echo ""

# USERNAME prompt
read -p "Enter the username to create: " USERNAME
if [ -z "$USERNAME" ]; then
  echo "Username cannot be empty"
  exit 1
fi
export USERNAME

# PASSWORD prompt
echo "Enter password for user '$USERNAME':"
read -s PASSWORD
if [ -z "$PASSWORD" ]; then
  echo "Password cannot be empty"
  exit 1
fi
export PASSWORD

# PASSWORD_CONFIRM prompt
echo "Confirm password for user '$USERNAME':"
read -s PASSWORD_CONFIRM
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match"
  exit 1
fi

# SUDO_PRIVILEGES prompt
read -p "Should the user '$USERNAME' have sudo privileges? (y/N): " SUDO_PRIVILEGES
if [[ "$SUDO_PRIVILEGES" =~ ^[Yy]$ ]]; then
  SUDO_PRIVILEGES=true
else
  SUDO_PRIVILEGES=false
fi
export SUDO_PRIVILEGES

# CODE_SERVER_PORT prompt
read -p "Enter port for code-server (default: 8080): " CODE_SERVER_PORT
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
export CODE_SERVER_PORT

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

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

# Create temporary directory for setup scripts
tmp_dir="/tmp/server-setup"
mkdir -p "$tmp_dir"

# Run setup modules
download_and_run() {
    local script="$1"
    local tmp_file="$tmp_dir/$script"
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file"
    chmod +x "$tmp_file"
    bash "$tmp_file"
}

download_and_run "user-setup.sh"
download_and_run "install-packages.sh"
download_and_run "code-server.sh"
download_and_run "postgres.sh"
download_and_run "nginx.sh"
download_and_run "certbot.sh"
download_and_run "nvm.sh"
download_and_run "pyenv.sh"
download_and_run "bash-aliases.sh"

# Cleanup
rm -rf "$tmp_dir"

# Finalize setup
echo "✅ Server setup complete at $(date)"
echo "Setup log can be found at ${LOG_FILE}"
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
echo "############## Reboot ##############"
echo "To apply some system updates, it is recommended to reboot the server.";
echo "You can do this by running 'sudo reboot' or 'sudo shutdown -r now'."

# End of script