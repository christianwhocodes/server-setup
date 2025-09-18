#!/bin/bash 
set -e 

# Source bashrc to ensure nvm is available
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Alternative: directly source nvm if bashrc doesn't work
if ! command -v nvm &> /dev/null; then
    if [ -f "$HOME/.nvm/nvm.sh" ]; then
        source "$HOME/.nvm/nvm.sh"
    elif [ -f "/usr/local/share/nvm/nvm.sh" ]; then
        source "/usr/local/share/nvm/nvm.sh"
    else
        echo "❌ Error: nvm not found. Please ensure nvm is properly installed."
        exit 1
    fi
fi

# Verify nvm is now available
if ! command -v nvm &> /dev/null; then
    echo "❌ Error: nvm is still not available after sourcing."
    exit 1
fi

echo "✅ nvm is available: $(nvm --version)"

# Install Node JS (latest LTS version)
echo "📦 Installing Node.js..."
nvm install node
nvm use node

# Update npm and install global packages
echo "📦 Updating npm and installing global packages..."
npm install -g npm@latest pm2 eslint

# Install Python using uv
echo "🐍 Installing Python..."
if command -v uv &> /dev/null; then
    uv python install
else
    echo "⚠️  Warning: uv not found. Skipping Python installation."
fi

# Verify installations
echo ""
echo "=== Installation Summary ==="
if command -v node &> /dev/null; then
    echo "✅ Node version: $(node -v)"
else
    echo "❌ Node: Not installed"
fi

if command -v npm &> /dev/null; then
    echo "✅ NPM version: $(npm -v)"
else
    echo "❌ NPM: Not installed"
fi

if command -v python3 &> /dev/null; then
    echo "✅ Python version: $(python3 --version)"
else
    echo "❌ Python3: Not installed"
fi

echo ""
echo "🎉 Setup complete!"