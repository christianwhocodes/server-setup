# Server Setup (user)
Automated user setup script for a remote Linux (Ubuntu) server.
## Usage

### Prerequisites

To create a new user, login as root follow the steps below

```bash
ssh root@example.com
```

```bash
adduser new_user
```

_(Optional)_ Give the user sudo privileges:

```bash
usermod -aG sudo new_user
```

_(Optional)_ Allow the user to login via passwordless (ssh-key) ssh:

```bash
rsync --archive --chown=new_user:new_user ~/.ssh /home/new_user
```

### Quick Setup
Login as the new user

```bash
ssh new_user@example.com
```

Run the command on your new user fresh logged-in session:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.sh)"
```

After which restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

### Alternative (Safer) Method
If you prefer to review the script before running it, first download it:

```bash
curl -O https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.sh
```

Review the script:

```bash
cat setup.sh
```

Make it executable and run:

```bash 
chmod +x setup.sh
bash ./setup.sh
```

After which restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

## What This Script Does

- Creates a github folder in the `/home/[USER]` directory for keeping code repos.
- Creates Code Server config file for the user
- Sets up bash aliases for the user
- Cleans up temporary files

## Node Js Configuration
Install node and npm run
```bash
nvm install node
```

```
nvm install <version>
```

You may want to start by installing some global packages

```bash
npm install -g npm@latest pm2
```

## Python Configuration
Install python and pip run
```bash
# Check for successful pyenv Installation:
pyenv versions

# List Python versions available in pyenv
pyenv install -l

# Install preferred Python version e.g. 3.13.6
pyenv install 3.13.6

# Set your version to be recognized globally within your user space
pyenv global 3.13.6

# Or set it locally per project
pyenv local 3.13.6

# Check either the system-wide, user-global or the local Python version is in use
pyenv prefix
```

You may want to start by installing some global packages and perhaps configure some settings

```bash
pip install --upgrade pip poetry jupyter
```

```bash
poetry config virtualenvs.in-project true
```

## Code Server Configuration

Request system admin to enable the code-server service for you. The system admin can run the following command:

```bash
sudo systemctl enable --now code-server@new_user
```

The system admin can then configure NGINX to reverse proxy to code-server under a domain e.g 'https://developer.example.com/$USER'. You can then access code-server at that domain.
