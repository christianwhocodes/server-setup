# 🏗️ Foundry

Automatically setup your Linux server with development tools and services using granular, idempotent GitHub Actions workflows!

## 🚀 Quick Start

1. **Fork this repository** - You'll need your own copy to store secrets
2. **Add your SSH key** to GitHub Secrets as `SERVER_SSH_KEY`
3. **Set your sudo user** in GitHub Secrets as `SUDO_ACCESS_USER`
4. **Run the workflow** - Actions → Setup Server → Choose your modules!

## ✨ Setup Profiles

Choose from pre-configured profiles or create your own custom setup:

### 📦 Full Development Server

Everything you need for a complete development environment:

- **System:** OpenSSH/UFW, Packages, Nginx, Certbot, Code-server, PostgreSQL
- **User:** uv, nvm, repos directory, Git/SSH
- **Perfect for:** Brand new development server from scratch

### 🖥️ System Services Only

Just the infrastructure without user tools:

- **System:** OpenSSH/UFW, Packages, Nginx, Certbot, Code-server, PostgreSQL
- **Perfect for:** Production servers or shared infrastructure

### 👤 User Tools Only

Development tools for a specific user:

- **User:** uv, nvm, repos directory, Git/SSH
- **Perfect for:** Adding a new developer to an existing server

### 🔧 Custom Profile

Use repository variables for fine-grained control:

- Configure exactly which modules to install via GitHub Variables
- **Perfect for:** Unique setups or gradual migrations

## 🎯 Available Modules

**System Modules** (requires sudo):

- 🔥 **OpenSSH & UFW** - Firewall and SSH configuration
- 🛠️ **Development Packages** - Essential build tools and libraries
- 🌐 **Nginx** - Web server and reverse proxy
- 🔒 **Certbot** - SSL certificate management
- 💻 **Code Server** - VS Code in the browser (system install + user config + service)
- 🐘 **PostgreSQL** - Relational database server

**User Modules** (per-user):

- 🐍 **uv** - Python package manager with automatic Python installation
- 📗 **nvm** - Node.js version manager with automatic Node.js installation
- 📁 **Repos Directory** - Creates `~/repos` folder for projects
- ⚙️ **Git Configuration** - Sets up global Git user name and email
- 🔑 **SSH Keys** - Generates ed25519 SSH key pair for Git operations

**Key Features:**

- ✅ Simple profiles - choose preset configurations or customize
- ✅ Idempotent - safe to run multiple times without breaking existing setups
- ✅ User management - automatically create users with optional sudo access
- ✅ No manual SSH required - scripts executed directly from GitHub
- ✅ No temporary files - scripts run directly via curl from raw GitHub URLs
- ✅ Modular scripts - each tool in its own file for easy maintenance
- ✅ Version-controlled execution - always uses scripts from the specific commit

## 📋 Prerequisites

- Fresh Linux server (tested on Ubuntu 24.04)
- A user with passwordless sudo access (e.g., `ubuntu`, `root`)
- Internet connection
- Fork of this repository

## 🔧 Setup Instructions

### 1. Configure GitHub Secrets

Navigate to your repository's **Settings** → **Secrets and variables** → **Actions** → **Secrets**:

**Required Secrets:**

| Secret Name        | Description                       | Value                                   |
| ------------------ | --------------------------------- | --------------------------------------- |
| `SERVER_SSH_KEY`   | SSH private key for server access | Entire content of your private key file |
| `SUDO_ACCESS_USER` | User with passwordless sudo       | `ubuntu` or `root`                      |

**Important Notes:**

- The public key corresponding to `SERVER_SSH_KEY` must be in your sudo user's `~/.ssh/authorized_keys` on the server
- `SUDO_ACCESS_USER` must already exist on the server with passwordless sudo access and SSH access using the `SERVER_SSH_KEY`

### 2. Configure GitHub Variables

In the same section, switch to the **Variables** tab:

**Optional Variables:**

| Variable Name            | Description                  | Default   |
| ------------------------ | ---------------------------- | --------- |
| `NVM_VERSION`            | Node Version Manager version | `v0.40.3` |
| `CODE_SERVER_PORT_START` | Code server port range start | `8080`    |
| `CODE_SERVER_PORT_END`   | Code server port range end   | `8100`    |

See [VARIABLES.md](.github/VARIABLES.md) for more details.

### 3. (Optional) Configure Custom Profile Variables

If you want to use the "Custom" profile for fine-grained control, add these boolean variables to specify exactly which modules to install:

**System Module Variables:**

- `SETUP_OPENSSH_UFW` - Setup OpenSSH and UFW (true/false)
- `SETUP_PACKAGES` - Install development packages (true/false)
- `SETUP_NGINX` - Setup Nginx (true/false)
- `SETUP_CERTBOT` - Setup Certbot (true/false)
- `SETUP_CODE_SERVER` - Setup code-server (system + user + service) (true/false)
- `SETUP_POSTGRES` - Setup PostgreSQL (true/false)

**User Module Variables:**

- `SETUP_UV` - Install uv (true/false)
- `SETUP_NVM` - Install nvm (true/false)
- `SETUP_REPOS_DIR` - Create repos directory (true/false)
- `SETUP_GIT_SSH` - Setup Git and SSH (true/false)

See [VARIABLES.md](.github/VARIABLES.md) for complete details.

### 4. Choose Your Setup Profile

The workflow now uses **profiles** instead of individual checkboxes:

## 💡 Common Use Cases

### 🎯 Full Development Server (Use Profile: "Full Development Server")

Create a new user with complete development environment - **just select the profile and fill in user details!**

**Perfect for:** Setting up a brand new development server from scratch

---

### 👤 Add User to Existing Server (Use Profile: "User Tools Only")

Just user-level tools without touching system services - **select profile, provide Git credentials for SSH key generation!**

**Perfect for:** Adding a new developer to an already configured server

**Note:** This profile includes Git/SSH setup, so git_user_name and git_user_email are required.

---

### 🖥️ System Services Only (Use Profile: "System Services Only")

Install system-wide services without user configuration - **infrastructure setup only!**

**Perfect for:** Setting up a production server or shared infrastructure

---

### 🔧 Add Single Module (Use Profile: "Custom")

Install one specific module using custom variables:

1. Go to repository **Variables**
2. Set only the module you want (e.g., `SETUP_NVM=true`)
3. Run workflow with "Custom (use repository variables)" profile
4. If `SETUP_GIT_SSH=true`, provide git_user_name and git_user_email in workflow inputs

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
   - Receives user-level configurations (uv, nvm, etc.)
   - Can optionally be given sudo access when created

**SSH Keys:**

- `SERVER_SSH_KEY`: Used by GitHub Actions to connect to the server (add to `SUDO_ACCESS_USER`'s authorized_keys)
- `ssh_public_key` (input): Optional public key for the new `target_user` (only when creating a user)

### 4. Run the Workflow

1. Go to **Actions** → **Setup Server**
2. Click **Run workflow**
3. Fill in the inputs:
   - **Server host**: Your server IP or hostname
   - **Server port**: SSH port (default: `22`)
   - **Target user**: User to setup (will be created if doesn't exist)
   - **Setup profile**: Choose from dropdown:
     - Full Development Server
     - System Services Only
     - User Tools Only
     - Custom (use repository variables)
4. Configure user creation options (if needed):
   - **Create user if missing**: Auto-create the user
   - **Make user sudo**: Give new user passwordless sudo access
   - **SSH public key**: Add SSH key for passwordless login to new user

5. Provide Git configuration (required if Git/SSH setup is enabled):
   - **Git user name**: Your name for Git commits (required when Git/SSH setup is part of the selected profile)
   - **Git user email**: Your email for Git commits (required when Git/SSH setup is part of the selected profile)

6. Click **Run workflow** and watch the magic happen!

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
3. **Start developing!** - Your server is ready to use

### 💻 Code-Server Security

The code-server setup includes enhanced security:

- Config file is owned by the sudo user (root)
- Target user can read the config but cannot modify it
- Password is protected from unauthorized changes
- Service runs as the target user: `code-server@[target_user]`

## 📁 Repository Structure

```
foundry/
├── .github/
│   ├── workflows/
│   │   └── setup-server.yml       # Main workflow file
│   ├── DEPLOYMENT_GUIDE.md        # Detailed deployment guide
│   └── VARIABLES.md               # Configuration reference
├── scripts/
│   ├── openssh-ufw.sh            # OpenSSH & UFW setup
│   ├── packages.sh               # Development packages
│   ├── nginx.sh                  # Nginx web server
│   ├── certbot.sh                # SSL certificates
│   ├── postgres.sh               # PostgreSQL database
│   ├── code-server.sh            # Code-server (unified)
│   ├── uv.sh                     # Python package manager
│   ├── nvm.sh                    # Node.js version manager
│   ├── repos.sh                  # Repos directory
│   └── git-ssh.sh                # Git & SSH keys
└── README.md                     # This file
```

## 📖 Documentation

- [DEPLOYMENT_GUIDE.md](.github/DEPLOYMENT_GUIDE.md) - Detailed deployment instructions and scenarios
- [VARIABLES.md](.github/VARIABLES.md) - Configuration options and secrets reference

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
