#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/christianwhocodes/server-setup/main/scripts"

echo "=== Server Setup Configuration ==="
echo ""

# USERNAME
if [ -z "$USERNAME" ]; then
  read -p "Enter the username to create: " USERNAME
  if [ -z "$USERNAME" ]; then
    echo "Username cannot be empty"
    exit 1
  fi
else
  echo "Using USERNAME from environment: $USERNAME"
fi

# PASSWORD
if [ -z "$PASSWORD" ]; then
  echo "Enter password for user '$USERNAME':"
  read -s PASSWORD
  if [ -z "$PASSWORD" ]; then
    echo "Password cannot be empty"
    exit 1
  fi
else
  echo "Using PASSWORD from environment"
fi

# PASSWORD_CONFIRM
if [ -z "$PASSWORD_CONFIRM" ]; then
  echo "Confirm password for user '$USERNAME':"
  read -s PASSWORD_CONFIRM
  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match"
    exit 1
  fi
else
  if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match"
    exit 1
  fi
fi

# SUDO_PRIVILEGES
if [ -z "$SUDO_PRIVILEGES" ]; then
  read -p "Should the user '$USERNAME' have sudo privileges? (y/N): " SUDO_PRIVILEGES
  if [[ "$SUDO_PRIVILEGES" =~ ^[Yy]$ ]]; then
    SUDO_PRIVILEGES=true
  else
    SUDO_PRIVILEGES=false
  fi
else
  echo "Using SUDO_PRIVILEGES from environment: $SUDO_PRIVILEGES"
fi

# CODE_SERVER_PORT
if [ -z "$CODE_SERVER_PORT" ]; then
  read -p "Enter port for code-server (default: 8080): " CODE_SERVER_PORT
  CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
else
  echo "Using CODE_SERVER_PORT from environment: $CODE_SERVER_PORT"
fi

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
if [ -z "$AUTO_CONFIRM" ]; then
  read -p "Proceed with setup? (y/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
else
  echo "Auto-confirm enabled, proceeding..."
fi

# Setup logging
LOG_FILE="/var/log/server-setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "${LOG_FILE}") 2>&1

# Set non-interactive mode for apt-get
export DEBIAN_FRONTEND=noninteractive

# Pass environment variables to scripts
export USERNAME PASSWORD SUDO_PRIVILEGES CODE_SERVER_PORT

# Run setup modules
download_and_run() {
    curl -fsSL "$BASE_URL/$1" | sudo bash
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

# Finalize setup
echo "✅ Server setup complete at $(date)"
echo "Setup log can be found at ${LOG_FILE}"
echo "To apply some changes, restart shell by running 'source ~/.bashrc' or 'exec "$SHELL"' or opening a new terminal."

# End of script