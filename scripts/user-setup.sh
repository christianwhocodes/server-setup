#!/bin/bash
set -e

# Check for required environment variables
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
  echo "Error: USERNAME and PASSWORD environment variables must be set."
  exit 1
fi

# Create user if not exists
if id "$USERNAME" &>/dev/null; then
  echo "User '$USERNAME' already exists."
else
  echo "Creating user '$USERNAME'..."
  adduser --gecos "" --disabled-login "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Add to groups if needed
if [ "$SUDO_PRIVILEGES" = true ]; then
  echo "Adding '$USERNAME' to sudo groups..."
  usermod -aG sudo "$USERNAME"
else
  echo "User '$USERNAME' will not have sudo privileges."
fi

# Setup GitHub folder
if [ ! -d "/home/$USERNAME/github" ]; then
  echo "Creating /home/$USERNAME/github directory..."
  mkdir -p "/home/$USERNAME/github"
fi

chmod -R 700 "/home/$USERNAME/github"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/github"

echo "✓ User $USERNAME setup complete"
