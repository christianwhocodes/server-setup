# 🏗️ Foundry

Automatically setup your Linux server with development tools and services!

## 📋 Requirements

- Fresh Linux server (tested on Ubuntu 24.04)
- Root or sudo access (for system setup)
- Internet connection

## 🚀 Setup Options

You can set up your server in two ways:

1. **Automated Setup** - Use GitHub Actions to set up remotely (Recommended)
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

## 🤖 Automated Setup with GitHub Actions

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

1. Go to **Actions** → **Setup Server**
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

## 📦 Workflow Outputs

After the workflow finishes, review the run logs for:

- Code Server configuration (port and password)
- Generated SSH public key ready for your Git host

---

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
