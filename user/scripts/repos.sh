#!/bin/bash
set -e

TARGET_DIR="/home/$USER/repos"

# Create the directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
  sudo mkdir -p "$TARGET_DIR"
fi
