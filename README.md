# 🏗️ Foundry

Automated setup scripts for a remote Linux (Ubuntu) server.

## 📋 Requirements

- Fresh Ubuntu server (tested on Ubuntu 24.04)
- Root or sudo access (for global setup)
- Internet connection

---

## 🌍 Global Setup

Automated global setup script for a remote Linux (Ubuntu) server.

### ✨ What Global Setup Does

- 💻 Installs Code Server
- 🌐 Installs and configures Nginx
- 🔒 Installs and configures Certbot
- 🐘 Installs PostgreSQL
- 🛠️ Installs essential development packages

### ⚠️ Security Note

The global setup requires:

- Root/sudo privileges for installing packages

### 📚 Prerequisites

Ensure you have an updated system:

```bash
sudo apt update && sudo apt upgrade -y
```

It is recommended you reboot the system as some system updates may require rebooting the server to take effect:

| Method 1      | Method 2               |
| ------------- | ---------------------- |
| `sudo reboot` | `sudo shutdown -r now` |

Unless you have the need to, we highly recommend allowing OpenSSH in the FireWall list:

```bash
sudo apt install ufw
sudo ufw allow OpenSSH
sudo ufw enable
```

### 🚀 Global Quick Setup

**Step 1:** Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/global/setup.sh)"
```

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

---

## 👤 User Setup

Automated user setup script for a remote Linux (Ubuntu) server.

### ✨ What User Setup Does

- ⚙️ Creates Code Server config file for the user
- 📗 Installs uv Python package manager (Does not install Python)
- 📗 Install nvm Node package manager (Does not install Nodejs and npm themselves)
- 📁 Creates a `repos` folder in the `/home/[USER]` directory
- 🔧 Sets up bash aliases
- ⚙️ Configures Git global user name and email
- 🔑 Generates and configures SSH key (id_ed25519)

### 📚 User Prerequisites

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

### 🚀 User Quick Setup

Login as the new user:

| Standard Login              | With SSH Key                                |
| --------------------------- | ------------------------------------------- |
| `ssh developer@example.com` | `ssh -i /path/to/key developer@example.com` |

**Step 1:** Run the command on your new user fresh logged-in session:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.sh)"
```

> ⚠️ Important: The script will output:
> - Your Code Server password and port number for server access
> - Your SSH public key which needs to be added to your Git hosting service (GitHub, GitLab, etc.)
> 
> Save both of these for future use.

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

**Step 3 (Optional):** Install Node.js, Python, and global packages:

```bash
nvm install node
npm install -g npm@latest vsce pm2 eslint
uv python install
```

---

## 👤 Post User Setup

Automated post-user setup script for configuring Code Server with Nginx and SSL.

### ✨ What Post User Setup Does

- 🔄 Enables Code Server systemd service
- 🌐 Configures Nginx reverse proxy
- 🔒 Sets up SSL certificate with Certbot
- 🔗 Links Code Server to your domain

### ⚠️ Security Note

The post-user setup requires:

- A registered domain name pointing to your server
- Port 80 and 443 open in your firewall
- Root/sudo privileges for Nginx and SSL configuration

### 📚 Prerequisites

Before running the post-user setup, point your domain to your server's IP address.

### 🚀 Quick Setup

Run this command to start the post-user configuration:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/post-user/setup.sh)"
```

After setup, access Code Server at: `https://your-domain.com`
