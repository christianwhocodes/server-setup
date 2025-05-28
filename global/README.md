# Server Setup (global)
Automated global setup script for a remote Linux (Ubuntu) server.
## Usage

### Prerequisites
- Ensure you have an updated system

```bash
sudo apt update && sudo apt upgrade -y
```

- Unless you have the need to, we highly recommend allowing OpenSSH in the FireWall list

```bash
sudo apt install ufw
ufw allow OpenSSH
ufw enable
```

### Quick Setup
Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/server-setup/main/global/setup.sh)"
```

### Alternative (Safer) Method
If you prefer to review the script before running it:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/christianwhocodes/server-setup/main/global/setup.sh

# Review the script
cat setup.sh

# Make it executable and run
chmod +x setup.sh
bash ./setup.sh
```

## What This Script Does

- Updates system packages
- Configures firewall (UFW)
- Installs and configures Nginx
- Installs and configures Certbot
- Installs Code Server
- Installs PostgreSQL
- Installs essential development packages
- Cleans up temporary files

## Requirements

- Fresh Ubuntu server (tested on Ubuntu 20.04/22.04)
- Root or sudo access
- Internet connection

## Security Note

This script requires root user to install packages and configure global services. Always review scripts before running them with sudo privileges.
