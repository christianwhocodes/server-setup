# 🏗️ Foundry

Automatically setup your Linux server with development tools and services!

## 📋 Requirements

- Fresh Linux server (tested on Ubuntu 24.04)
- Root or sudo access (for system setup)
- Internet connection

## 🚀 Setup Options

You can set up your server in two ways:

1. **Automated Deployment** - Use GitHub Actions to deploy remotely (Recommended)
2. **Manual Setup** - Run scripts directly on your server via SSH

## ✨ What Gets Installed

**System Setup:**

- 🌐 Installs and configures Nginx
- 🔒 Installs and configures Certbot
- 💻 Installs Code Server
- 🐘 Installs PostgreSQL
- 🛠️ Installs essential development packages

**User Setup:**

- ⚙️ Creates Code Server config file for the user
- 📗 Installs uv Python package manager (Does not install Python)
- 📗 Installs nvm Node package manager (Does not install Nodejs and npm themselves)
- 📁 Creates a `repos` folder in the `/home/[USER]` directory
- ⚙️ Configures Git global user name and email
- 🔑 Generates and configures SSH key (id_ed25519)

---

## 🤖 Automated Deployment with GitHub Actions

Deploy and configure your server automatically using GitHub Actions - no manual SSH required!

### 🎯 Benefits

- ✅ No manual copy-pasting of scripts
- ✅ Consistent deployments across multiple servers
- ✅ Version-controlled configuration
- ✅ Easy to customize with repository variables
- ✅ Audit trail of all deployments

### 📚 Prerequisites

1. **Server SSH Key**: Generate an SSH key pair for server access
2. **GitHub Repository**: Fork this repository or use your own
3. **GitHub Secrets**: Add your SSH private key as a secret
4. **GitHub Variables** (optional): Configure custom values

### 🔧 Setup Instructions

#### 1. Add SSH Key to GitHub Secrets

Navigate to your repository's **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

- **Name**: `SERVER_SSH_KEY`
- **Value**: Your SSH private key content (the entire content of your private key file)

#### 2. Configure Repository Variables (Optional)

Navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab → **New repository variable**:

| Variable Name            | Description                  | Default Value |
| ------------------------ | ---------------------------- | ------------- |
| `NVM_VERSION`            | Node Version Manager version | `v0.40.3`     |
| `CODE_SERVER_PORT_START` | Code server port range start | `8080`        |
| `CODE_SERVER_PORT_END`   | Code server port range end   | `8100`        |

Note: The workflow always uses the repository and commit that triggered the run. There are no overrides via REPO*\* variables. REPO*\* variables shown below are only for manual setup.

#### 3. Run the Workflow

1. Go to **Actions** → **Deploy Server Setup**
2. Click **Run workflow**
3. Fill in the required inputs:
   - **Setup type**: Choose `system`, `user`, or `both`
   - **Server host**: Your server IP or hostname
   - **Server user**: SSH user (e.g., `root` for system, `developer` for user)
   - **Server port**: SSH port (default: `22`)
   - **Git user name**: Your Git name (required for user setup)
   - **Git user email**: Your Git email (required for user setup)
4. Click **Run workflow**

The workflow will:

- Connect to your server via SSH
- Run the appropriate setup scripts based on your selection
- Display post-setup instructions

---

## 🌍 Manual Setup: Global (System) Setup

Automated system setup bash script for a remote Linux (Ubuntu) server _(sudo required)_.

### 📚 Prerequisites

Ensure you have an updated system:

```bash
sudo apt update && sudo apt upgrade -y
```

It is recommended you reboot the system as some system updates may require rebooting the server to take effect:

```bash
sudo reboot
```

Unless you have the need to, we highly recommend allowing OpenSSH in the FireWall list:

```bash
sudo apt install ufw
sudo ufw allow OpenSSH
sudo ufw enable
```

### 🚀 Quick Setup

**Step 1:** Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/system/setup.sh)"
```

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

### 🔧 Advanced: Using Custom Repository

If you've forked this repository or want to use a different branch, you can set environment variables:

```bash
export REPO_OWNER="your-github-username"
export REPO_NAME="foundry"
export REPO_BRANCH="main"
bash -c "$(curl -sSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}/system/setup.sh)"
```

---

## 👤 Manual Setup: User Setup

Automated user setup bash script for a remote Linux (Ubuntu) server _(non-sudo)_.

### 📚 Prerequisites

To create a new user, login as root or a user with sudo privileges, then follow the steps below:

Create the user:

```bash
sudo adduser developer
```

_(Optional)_ Give the user sudo privileges:

```bash
sudo usermod -aG sudo developer
```

_(Optional)_ Allow the user to login via passwordless (ssh-key) ssh:

```bash
sudo rsync --archive --chown=developer:developer ~/.ssh /home/developer
```

### 🚀 Quick Setup

Login as the new user:

| Standard Login              | With SSH Key                                |
| --------------------------- | ------------------------------------------- |
| `ssh developer@example.com` | `ssh -i /path/to/key developer@example.com` |

**Step 1:** Run the command on your new user fresh logged-in session:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.sh)"
```

> ⚠️ Important: The script will output:
>
> - Your Code Server password and port number for server access
> - Your SSH public key which needs to be added to your Git hosting service (GitHub, GitLab, etc.)
>
> Save both of these for future use.

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

### 🔧 Advanced: Using Environment Variables

You can skip interactive prompts and customize settings by setting environment variables before running the setup:

```bash
# Required for non-interactive setup
export GIT_USER_NAME="John Doe"
export GIT_USER_EMAIL="john@example.com"

# Optional customizations
export REPO_OWNER="your-github-username"
export REPO_NAME="foundry"
export REPO_BRANCH="main"
export NVM_VERSION="v0.40.3"
export CODE_SERVER_PORT_START="8080"
export CODE_SERVER_PORT_END="8100"

# Run the setup
bash -c "$(curl -sSL https://raw.githubusercontent.com/${REPO_OWNER:-christianwhocodes}/${REPO_NAME:-foundry}/${REPO_BRANCH:-main}/user/setup.sh)"
```

**Step 3 (Optional):** Install Node.js, Python, and global packages:

```bash
nvm install node
npm install -g npm@latest pm2 eslint
uv python install
```

---

## 🔐 Manual Setup: Post User Setup

After completing the user setup, a sudo user or administrator must enable and start the code-server service for the new user _(sudo required)_.

### Enable Code Server Service

Login as root or a user with sudo privileges, then run:

```bash
sudo systemctl enable --now code-server@developer
```

Replace `developer` with the actual username you created.

### ✅ Verify Service Status

Check if the service is running properly:

```bash
sudo systemctl status code-server@developer
```

You should see the service as `active (running)`.

### 🌐 Access Code Server

Once the service is running, you can access Code Server at:

```
http://your-server-ip:8080
```

Use the password and port number provided during the user setup to login.

### 🔐 SSH Port Forwarding _(Recommended for Remote Access)_

For secure access from your local computer, use SSH port forwarding instead of exposing Code Server directly:

**With SSH Key:**

```bash
ssh -L 8080:localhost:8080 -i /path/to/key developer@your-server-ip
```

**Without SSH Key (password authentication):**

```bash
ssh -L 8080:localhost:8080 developer@your-server-ip
```

Then access Code Server locally at:

```
http://localhost:8080
```

This keeps your Code Server secure by not exposing it to the public internet.

---

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
