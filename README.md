# 🏗️ Foundry

Automatically setup your Linux server with development tools and services using granular, idempotent GitHub Actions workflows!

## 🚀 Quick Start

1. **Fork this repository** - You'll need your own copy to store secrets
2. **Add your SSH key** to GitHub Secrets as `SERVER_SSH_KEY`
3. **Set your sudo user** in GitHub Variables as `SUDO_ACCESS_USER`
4. **Run the workflow** - Actions → Setup Server → Choose your modules!

## ✨ Available Modules

**System Modules** (requires sudo):
- 🔥 **OpenSSH & UFW** - Firewall and SSH configuration
- 🛠️ **Development Packages** - Essential build tools and libraries
- 🌐 **Nginx** - Web server and reverse proxy
- 🔒 **Certbot** - SSL certificate management
- 💻 **Code Server** - VS Code in the browser (system-wide)
- 🐘 **PostgreSQL** - Relational database server

**User Modules** (per-user):
- ⚙️ **Code Server Config** - User-specific code-server setup
- 🐍 **uv** - Python package manager with automatic Python installation
- 📗 **nvm** - Node.js version manager with automatic Node.js installation
- 📁 **Repos Directory** - Creates `~/repos` folder for projects
- ⚙️ **Git Configuration** - Sets up global Git user name and email
- 🔑 **SSH Keys** - Generates ed25519 SSH key pair for Git operations

**Key Features:**
- ✅ Granular control - choose exactly which modules to install
- ✅ Idempotent - safe to run multiple times without breaking existing setups
- ✅ User management - automatically create users with optional sudo access
- ✅ No manual SSH or script copying required

## 📋 Prerequisites

- Fresh Linux server (tested on Ubuntu 24.04)
- A user with passwordless sudo access (e.g., `ubuntu`, `root`)
- Internet connection
- Fork of this repository

## 🔧 Setup Instructions

### 1. Configure GitHub Secrets

Navigate to your repository's **Settings** → **Secrets and variables** → **Actions**:

**Required Secret:**

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `SERVER_SSH_KEY` | SSH private key for server access | Entire content of your private key file |

**Important:** The corresponding public key must be in your sudo user's `~/.ssh/authorized_keys` on the server.

### 2. Configure GitHub Variables

In the same section, switch to the **Variables** tab:

**Required Variable:**

| Variable Name | Description | Example |
|---------------|-------------|---------|
| `SUDO_ACCESS_USER` | User with passwordless sudo | `ubuntu` or `root` |

**Note:** This user is used for system-level operations and must already exist on the server with:
- Passwordless sudo access
- SSH access using the `SERVER_SSH_KEY`

**Optional Variables:**

| Variable Name | Description | Default |
|---------------|-------------|---------|
| `NVM_VERSION` | Node Version Manager version | `v0.40.3` |
| `CODE_SERVER_PORT_START` | Code server port range start | `8080` |
| `CODE_SERVER_PORT_END` | Code server port range end | `8100` |

See [VARIABLES.md](.github/VARIABLES.md) for more details.

### 3. Choose Your Setup Scenario

Pick the workflow configuration that matches your needs:

## 💡 Common Use Cases

### 🎯 Full Development Server

Create a new user with complete development environment:

**System Modules:** ✅ All (OpenSSH/UFW, Packages, Nginx, Certbot, Code-server, PostgreSQL)  
**User Modules:** ✅ All (Code-server config, uv, nvm, repos directory, Git/SSH)  
**User Creation:** Create user (optionally with sudo and SSH access)

**Perfect for:** Setting up a brand new development server from scratch

---

### 👤 Add User to Existing Server

Just user-level tools without touching system services:

**System Modules:** ❌ None  
**User Modules:** ✅ All (Code-server config, uv, nvm, repos directory, Git/SSH)  
**User Creation:** Use existing user or create new user (optionally with sudo and SSH access)

**Perfect for:** Adding a new developer to an already configured server

---

### 🖥️ System Services Only

Install system-wide services without user configuration:

**System Modules:** ✅ All or selected (OpenSSH/UFW, Packages, Nginx, Certbot, PostgreSQL)  
**User Modules:** ❌ None  
**User Creation:** Not needed

**Perfect for:** Setting up a production server or shared infrastructure

---

### 🔧 Add Single Module

Install one new tool to an existing setup (idempotent):

**Any Modules:** ✅ Check only what you want to add  
**Existing setups:** Won't be affected - safe to rerun

**Perfect for:** Adding PostgreSQL to a server that already has Nginx, or adding nvm to a user who already has uv

---

## 🔑 Understanding User Management

**Two Types of Users:**

1. **SUDO_ACCESS_USER** (configured in GitHub Variables/Secrets)
   - Used for system operations (installing packages, configuring services)
   - Must already exist on the server
   - Needs passwordless sudo and SSH access with `SERVER_SSH_KEY`
   - Example: `ubuntu`, `root`, or your admin user

2. **target_user** (specified in workflow inputs)
   - The user you want to configure with development tools
   - Can be created automatically if it doesn't exist
   - Receives user-level configurations (code-server, nvm, uv, etc.)
   - Can optionally be given sudo access when created

**SSH Keys:**
- `SERVER_SSH_KEY`: Used by GitHub Actions to connect to the server (add to `SUDO_ACCESS_USER`'s authorized_keys)
- `ssh_public_key` (input): Optional public key for the new `target_user` (only when creating a user)

### 4. Run the Workflow

1. Go to **Actions** → **Setup Server**
2. Click **Run workflow**
3. Fill in the required inputs:
   - **Server host**: Your server IP or hostname
   - **Server port**: SSH port (default: `22`)
   - **Target user**: User to setup (will be created if doesn't exist)
   
4. Configure user creation options (if needed):
   - **Create user if missing**: Auto-create the user
   - **Make user sudo**: Give new user passwordless sudo access
   - **SSH public key**: Add SSH key for passwordless login to new user

5. Select your modules based on the scenario above

6. Provide Git configuration if setting up Git/SSH modules

7. Click **Run workflow** and watch the magic happen!

## 📦 After Deployment

### Check Workflow Outputs

After the workflow completes, check the **Summary** tab for:

- 🔐 Code-server access URL and password
- 🔑 Generated SSH public key (add this to GitHub/GitLab)
- 📝 Important post-setup notes and next steps
- ⚠️ Any warnings or manual steps required

### Next Steps

1. **Add SSH key to Git hosting** - Copy the displayed public key to GitHub/GitLab/etc.
2. **Access code-server** - Use the provided URL and password
3. **Enable code-server service** - If not auto-enabled, run the command shown in summary
4. **Start developing!** - Your server is ready to use

## 📖 Documentation

- [DEPLOYMENT_GUIDE.md](.github/DEPLOYMENT_GUIDE.md) - Detailed deployment instructions and scenarios
- [VARIABLES.md](.github/VARIABLES.md) - Configuration options and secrets reference

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
