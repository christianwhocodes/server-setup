# server-setup
Automated setup script for remote Linux (Ubuntu) servers - installs users, Python, Node.js, PostgreSQL, Nginx, and code-server

## Usage

### Quick Setup
Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
curl -sSL https://raw.githubusercontent.com/christianwhocodes/server-setup/main/setup.sh | sudo bash
```

### Alternative (Safer) Method
If you prefer to review the script before running it:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/christianwhocodes/server-setup/main/setup.sh

# Review the script
cat setup.sh

# Make it executable and run
chmod +x setup.sh
sudo ./setup.sh
```

## What This Script Does

- Updates system packages
- Configures firewall (UFW)
- Installs essential development packages
- Creates user accounts
- Sets up PostgreSQL with user databases
- Installs and configures Nginx
- Cleans up temporary files

## Requirements

- Fresh Ubuntu server (tested on Ubuntu 20.04/22.04)
- Root or sudo access
- Internet connection

## Logs

Setup logs are saved to `/var/log/server-setup.log` for troubleshooting.

## Security Note

This script requires root user to install packages and configure system services. Always review scripts before running them with sudo privileges.
