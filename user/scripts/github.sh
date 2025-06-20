#!/bin/bash
set -e

# Setup GitHub folder
if [ ! -d "/home/$USER/repos" ]; then
  echo "Creating /home/$USER/repos directory..."
  mkdir -p "/home/$USER/repos"
fi

chmod -R 700 "/home/$USER/repos"
chown -R "$USER:$USER" "/home/$USER/repos"
