#!/bin/bash 
set -e 

# Install Node JS
nvm install node


# Update npm and install global packages
npm install -g npm@latest pm2 eslint

# Install Python
uv python install

# Verify installations
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "Python version: $(python3 --version)"
