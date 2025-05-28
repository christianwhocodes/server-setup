# Server Setup (user)
Automated user setup script for a remote Linux (Ubuntu) server.
## Usage

### Prerequisites
The setup script should be run in a logged in terminal session

To create a new user, login as root follow the steps below

```bash
ssh root@example.com
```

```bash
adduser new_user

# Give the user sudo privileges (Optional)
usermod -aG sudo new_user

# Allow the user to login via passwordless (ssh-key) ssh (Optional)
rsync --archive --chown=new_user:new_user ~/.ssh /home/new_user
```

### Quick Setup
Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/server-setup/main/user/setup.sh)"
```

### Alternative (Safer) Method
If you prefer to review the script before running it:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/christianwhocodes/server-setup/main/user/setup.sh

# Review the script
cat setup.sh

# Make it executable and run
chmod +x setup.sh
bash ./setup.sh
```

## What This Script Does

- Creates a github folder in the `/home/[USER]` directory for keeping code repos.
- Sets up Code Server for the user
- Sets up bash aliases for the user
- Installs and configures NVM, node and npm
- Installs and configures Pyenv, python and pip
- Cleans up temporary files

## Requirements
- Fresh Ubuntu server (tested on Ubuntu 20.04/22.04)
- Internet connection
