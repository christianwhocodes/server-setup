#!/bin/bash
set -e

# Setup GitHub folder
if [ ! -d "/home/$USER/github" ]; then
  echo "Creating /home/$USER/github directory..."
  mkdir -p "/home/$USER/github"
fi

chmod -R 700 "/home/$USER/github"
chown -R "$USER:$USER" "/home/$USER/github"