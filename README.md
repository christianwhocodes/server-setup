# Server Setup
Automated setup script for remote Linux (Ubuntu) servers - installs users, Python, Node.js, PostgreSQL, Nginx, and code-server

## Usage

### A. Quick Setup

#### One-line (non-interactive) setup

Set environment variables inline to skip prompts:

```bash
USERNAME=myuser PASSWORD=mypassword SUDO_PRIVILEGES=true CODE_SERVER_PORT=8080 PASSWORD_CONFIRM=mypassword AUTO_CONFIRM=1 curl -sSL https://raw.githubusercontent.com/christianwhocodes/server-setup/main/setup.sh | bash
```

- `USERNAME`: The username to create
- `PASSWORD`: The password for the user
- `PASSWORD_CONFIRM`: Must match `PASSWORD` (required for non-interactive)
- `SUDO_PRIVILEGES`: `true` or `false`
- `CODE_SERVER_PORT`: Port for code-server (default: 8080)
- `AUTO_CONFIRM`: Set to any value to skip the final confirmation prompt

### B. Alternative (Safer) Interactive Method
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
