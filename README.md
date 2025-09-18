# 🏗️ Foundry

Automated setup scripts for a remote Linux (Ubuntu) server.

## 📋 Requirements

- Fresh Ubuntu server (tested on Ubuntu 20.04/22.04)
- Root or sudo access (for global setup)
- Internet connection

## ⚠️ Security Note

The global setup script requires a root/sudo permission to install packages and configure global services. Always review scripts before running them with sudo privileges.

---

## 🌍 Global Setup

Automated global setup script for a remote Linux (Ubuntu) server.

### ✨ What Global Setup Does

- 💻 Installs Code Server
- 🌐 Installs and configures Nginx
- 🔒 Installs and configures Certbot
- 🐘 Installs PostgreSQL
- 🛠️ Installs essential development packages

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

### 📚 User Prerequisites

To create a new user, login as root or a user with sudo privileges, then follow the steps below:

Create the user:

```bash
sudo adduser developer
```

*(Optional)* Give the user sudo privileges:

```bash
sudo usermod -aG sudo developer
```

*(Optional)* Allow the user to login via passwordless (ssh-key) ssh:

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

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

**Step 3 (Optional):** Install Node.js, Python, and global packages:

```bash
nvm install node
npm install -g npm@latest pm2 eslint
uv python install
```

---

### 💻 Code Server Configuration

Request system admin to enable the code-server service for you. The system admin can run the following command:

```bash
sudo systemctl enable --now code-server@developer
```