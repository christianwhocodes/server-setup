#!/bin/bash
set -e

# Check if user is a sudoer
if sudo -l -U "$USER" &>/dev/null; then
  TARGET_DIR="/repos"
else
  TARGET_DIR="/home/$USER/repos"
fi

# Create the directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  echo "Creating $TARGET_DIR directory..."
  sudo mkdir -p "$TARGET_DIR"
fi

# Fix permissions if they don't match
CURRENT_OWNER=$(stat -c '%U' "$TARGET_DIR")
if [ "$CURRENT_OWNER" != "$USER" ]; then
  echo "Changing ownership of $TARGET_DIR to $USER..."
  sudo chown -R "$USER:$USER" "$TARGET_DIR"
fi

CURRENT_PERMS=$(stat -c '%a' "$TARGET_DIR")
if [ "$CURRENT_PERMS" != "700" ]; then
  echo "Setting permissions of $TARGET_DIR to 700..."
  sudo chmod -R 700 "$TARGET_DIR"
fi
