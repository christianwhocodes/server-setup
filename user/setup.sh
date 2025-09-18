#!/bin/bash 
set -e 
 
# ***************** Variables and Functions ***************** 
 
export DEBIAN_FRONTEND=noninteractive 
 
SETUP_TYPE="user" 
 
TMP_DIR="/home/$USER/foundry/$SETUP_TYPE" 
mkdir -p "$TMP_DIR" 
 
BASE_URL="https://raw.githubusercontent.com/christianwhocodes/foundry/main/$SETUP_TYPE/scripts" 
 
download_and_run() { 
    local script="$1" 
    local tmp_file="$TMP_DIR/$script" 
    curl -fsSL "$BASE_URL/$script" -o "$tmp_file" 
    chmod +x "$tmp_file" 
    bash "$tmp_file" 
} 

# Check if a port is in use
is_port_in_use() {
    local port=$1
    # Check if port is listening on any interface (TCP)
    if ss -tuln | grep -q ":$port "; then
        return 0  # Port is in use
    else
        return 1  # Port is available
    fi
}

# Find an available port in the specified range
find_available_port() {
    local start_port=$1
    local end_port=$2
    
    for port in $(seq $start_port $end_port); do
        if ! is_port_in_use $port; then
            echo $port
            return 0
        fi
    done
    
    return 1  # No available port found
}

# Find and configure code-server port
configure_code_server_port() {
    echo "Checking for available ports in range 8080-8100..."
    local port=$(find_available_port 8080 8100)

    if [ $? -ne 0 ] || [ -z "$port" ]; then
        echo "❌ No available ports found in range 8080-8100"
        echo "Please free up a port in this range or modify the script to use a different range."
        exit 1
    fi

    echo "✅ Found available port to use for code-server: $port"
    export CODE_SERVER_PORT=$port

    echo ""
    echo "- Code-server port: $port (auto-detected)"
    echo "- Starting setup..."
    echo ""
}

# ***************** Start of the script *****************

echo "=== Setup ($SETUP_TYPE) Configuration ==="
echo ""


# Set up code-server 
configure_code_server_port
download_and_run "code-server.sh" 

# Set up uv and python
download_and_run "uv.sh" 

# Set up nvm 
download_and_run "nvm.sh" 

# Set up repos folder 
download_and_run "repos.sh" 
 
# Set up bash aliases 
download_and_run "bash-aliases.sh" 
 
# Cleanup 
rm -rf "$TMP_DIR" 
 
# Final message 
echo "=== ✅ Finished Setup ($SETUP_TYPE) Configuration ===" 
echo "Code-server is configured to run on port $CODE_SERVER_PORT"

# ***************** End of the script *****************
