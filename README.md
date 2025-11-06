# 🏗️ Foundry

Automatically setup your Linux server with development tools and services using granular, idempotent GitHub Actions workflows!

## 📋 Requirements

- Fresh Linux server (tested on Ubuntu 24.04)
- A user with passwordless sudo access (for system-level operations)
- Internet connection

## ✨ What Gets Installed

**System Setup Modules** (requires sudo access):

- 🔥 **OpenSSH & UFW**: Configures firewall and SSH access
- 🛠️ **Development Packages**: Essential build tools and libraries
- 🌐 **Nginx**: Web server and reverse proxy
- 🔒 **Certbot**: SSL certificate management
- 💻 **Code Server**: VS Code in the browser (system-wide installation)
- 🐘 **PostgreSQL**: Relational database server

**User Setup Modules** (per-user configuration):

- ⚙️ **Code Server Config**: User-specific code-server configuration
- 📗 **uv**: Python package manager with automatic Python installation
- 📗 **nvm**: Node.js version manager with automatic Node.js installation
- 📁 **Repos Directory**: Creates `~/repos` folder for projects
- ⚙️ **Git Configuration**: Sets up global Git user name and email
- 🔑 **SSH Keys**: Generates ed25519 SSH key pair for Git operations

**Key Features:**

- ✅ **Granular Control**: Choose exactly which modules to install
- ✅ **Idempotent**: Safe to run multiple times without breaking existing setups
- ✅ **User Management**: Automatically create users with optional sudo access
- ✅ **Flexible**: Mix system-wide and per-user configurations

---

## 🤖 Automated Setup with GitHub Actions

Deploy and configure your server automatically using GitHub Actions - no manual SSH required!

### 🎯 Benefits

- ✅ Granular module selection - install only what you need
- ✅ Automatic user creation with optional sudo access
- ✅ Idempotent operations - safe to rerun
- ✅ No manual copy-pasting of scripts
- ✅ Consistent deployments across multiple servers
- ✅ Version-controlled configuration
- ✅ Easy to customize with repository variables
- ✅ Audit trail of all deployments

### 📚 Prerequisites

1. **Fork this repository**: You'll need your own copy to store SSH keys as secrets
2. **Server SSH Key**: Generate an SSH key pair for server access
3. **Sudo User**: A user with passwordless sudo access on the server (e.g., `ubuntu`, `root`)
4. **GitHub Secrets & Variables**: Configure required secrets and variables

### 🔧 Setup Instructions

#### 1. Add SSH Key to GitHub Secrets

Navigate to your repository's **Settings** → **Secrets and variables** → **Actions** → **Secrets** → **New repository secret**:

- **Name**: `SERVER_SSH_KEY`
- **Value**: Your SSH private key content (the entire content of your private key file)

Make sure the corresponding public key is in the sudo user's `~/.ssh/authorized_keys` on the server.

#### 2. Configure SUDO_ACCESS_USER

Navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab → **New repository variable**:

- **Name**: `SUDO_ACCESS_USER`
- **Value**: Username with passwordless sudo (e.g., `ubuntu`, `root`)

**Note:** This user is used for system-level operations. Required when using any system setup modules.

#### 3. Configure Repository Variables (Optional)

Navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab → **New repository variable**:

| Variable Name            | Description                  | Default Value |
| ------------------------ | ---------------------------- | ------------- |
| `NVM_VERSION`            | Node Version Manager version | `v0.40.3`     |
| `CODE_SERVER_PORT_START` | Code server port range start | `8080`        |
| `CODE_SERVER_PORT_END`   | Code server port range end   | `8100`        |

#### 4. Run the Workflow

1. Go to **Actions** → **Setup Server**
2. Click **Run workflow**
3. Fill in the required inputs:
   - **Server host**: Your server IP or hostname
   - **Server port**: SSH port (default: `22`)
   - **Target user**: User to setup (will be created if doesn't exist)
   
4. Configure user creation options (if user doesn't exist):
   - **Create user if missing**: Auto-create the user
   - **Make user sudo**: Give new user passwordless sudo access
   - **SSH public key**: Add SSH key for passwordless login

5. Select which modules to install:
   - **System modules**: Require `SUDO_ACCESS_USER` to be configured
   - **User modules**: Run as target user, no sudo required
   - **Git configuration**: Provide name and email if setting up Git

6. Click **Run workflow**

The workflow will:

- Connect to your server via SSH
- Create the target user if needed
- Run apt-get update (if any system modules selected)
- Execute selected system setup modules with sudo
- Execute selected user setup modules as the target user
- Display post-setup instructions and credentials

## 📦 Workflow Outputs

After the workflow finishes:

1. **Check the Summary tab** of the workflow run for:
   - Code-server port and password (if configured)
   - Direct access URL to code-server
   - Generated SSH public key (if Git/SSH configured)
   - Important post-setup notes

2. **Review the detailed logs** for:
   - Step-by-step execution details
   - Any warnings or additional information

**Next Steps:**

- Add the displayed SSH public key to your Git hosting service (GitHub, GitLab, etc.)
- Access code-server using the provided URL and password
- If code-server service wasn't enabled automatically, run the command shown in the summary

## 🚀 Common Workflows

### Full Development Server Setup

Create a new user with full development environment:

1. Set system modules: OpenSSH/UFW, Packages, Nginx, Certbot, Code-server (system), PostgreSQL
2. Set user modules: Code-server (user), uv, nvm, repos directory, Git/SSH
3. Configure: Create user, make sudo, add SSH key

### Add User to Existing Server

Just user-level tools for an existing user:

1. Leave all system modules unchecked
2. Set user modules: Code-server (user), uv, nvm, repos directory, Git/SSH
3. Configure: Use existing user

### System-Only Setup

Install system services without user configuration:

1. Set system modules: OpenSSH/UFW, Packages, Nginx, Certbot, PostgreSQL
2. Leave all user modules unchecked

### Add Single Module

Install one new tool to existing setup (idempotent):

1. Check only the module you want to add
2. Run workflow - existing installations won't be affected

---

## 📖 Documentation

- [DEPLOYMENT_GUIDE.md](.github/DEPLOYMENT_GUIDE.md) - Detailed deployment instructions and scenarios
- [VARIABLES.md](.github/VARIABLES.md) - Configuration options and secrets

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
