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
Login as the new user

```bash
ssh new_user@example.com
```

Copy and run the below code block on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/server-setup/main/user/setup.sh)"
source ~/.bashrc && exec /bin/bash
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

# Restart shell
source ~/.bashrc && exec /bin/bash
```

## What This Script Does

- Creates a github folder in the `/home/[USER]` directory for keeping code repos.
- Sets up Code Server for the user
- Sets up bash aliases for the user
- Cleans up temporary files

## Node Js Configuration
Install node and npm run
```bash
nvm install node

# or specific version
nvm install <version>
```

You may want to start by installing some global packages

```bash
npm install -g npm@latest serve pm2
```

## Python Configuration
Install python and pip run
```bash
# Check for successful pyenv Installation:
pyenv versions

# List Python versions available in pyenv
pyenv install -l

# Install preferred Python version e.g. 3.13.3
pyenv install 3.13.3

# Set your version to be recognized globally within your user space
pyenv global 3.13.3

# Or set it locally per project
pyenv local 3.13.3

# Check either the system-wide, user-global or the local Python version is in use
pyenv prefix
```

You may want to start by installing some global packages

```bash
pip install --upgrade pip poetry jupyter
```
