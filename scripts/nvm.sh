#!/bin/bash
set -e

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install node
npm install -g npm@latest serve pm2

echo "✓ NVM, Node and Npm installed"