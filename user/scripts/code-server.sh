#!/bin/bash
set -e

# Color variables
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if a port is in use
is_port_in_use() {
    local port=$1
    if ss -tuln | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

# Find an available port
find_available_port() {
    local start_port=$1
    local end_port=$2
    for port in $(seq $start_port $end_port); do
        if ! is_port_in_use $port; then
            echo $port
            return 0
        fi
    done
    return 1
}

# Configure port
echo -e "${BLUE}Checking for available ports in range 8080-8100...${NC}"
PORT=$(find_available_port 8080 8100)

if [ $? -ne 0 ] || [ -z "$PORT" ]; then
    echo -e "${RED}❌ No available ports found in range 8080-8100${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found available port: $PORT${NC}"

# Generate random password
RANDOM_PASS=$(openssl rand -base64 12)

# Write config values to temp files for parent script
echo "$RANDOM_PASS" > "$TMP_DIR/code-server-pass.tmp"

# This is for internal 'user' setup use only,
echo "$PORT" > "$TMP_DIR/code-server-port.tmp"

# While this is for 'post-user' code-server.sh to read
if ! echo "$PORT" > "/tmp/code-server-port.tmp"; then
    echo -e "${RED}❌ Failed to write port number to temporary file${NC}"
    exit 1
fi

# Configure code-server
mkdir -p "/home/$USER/.config/code-server"
rm -f "/home/$USER/.config/code-server/config.yaml"
cat <<EOF > "/home/$USER/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$PORT
auth: password
password: $RANDOM_PASS
cert: false
EOF
chown "$USER:$USER" "/home/$USER/.config/code-server/config.yaml"