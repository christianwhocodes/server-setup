# 🏗️ Foundry

Linux (Ubuntu) server-setup bash scripts for automation.

## 📋 Requirements

- Fresh Ubuntu server (tested on Ubuntu 24.04)
- Root or sudo access (for system setup)
- Internet connection

---

## 🌍 Global Setup _(sudo required)_

Automated system setup bash script for a remote Linux (Ubuntu) server.

### ✨ What Global Setup Does

- 🌐 Installs and configures Nginx
- 🔒 Installs and configures Certbot
- 💻 Installs Code Server
- 🐘 Installs PostgreSQL
- 🛠️ Installs essential development packages

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

### 🚀 Global Quick Setup

**Step 1:** Run this single command on your fresh Ubuntu server to automatically configure everything:

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/christianwhocodes/foundry/main/system/setup.sh)"
```

**Step 2:** Restart the session for changes to fully take effect:

```bash
source ~/.bashrc && exec /bin/bash
```

---

## 👤 User Setup _(non-sudo)_

Automated user setup bash script for a remote Linux (Ubuntu) server.

### ✨ What User Setup Does

- ⚙️ Creates Code Server config file for the user
- 📗 Installs uv Python package manager (Does not install Python)
- 📗 Install nvm Node package manager (Does not install Nodejs and npm themselves)
- 📁 Creates a `repos` folder in the `/home/[USER]` directory
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
>
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
npm install -g npm@latest pm2 eslint
uv python install
```

---

## 👤 Post User Setup _(sudo required)_

After completing the user setup, a sudo user or administrator must enable and start the code-server service for the new user.

### 🔐 Enable Code Server Service

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
