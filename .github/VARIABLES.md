# GitHub Repository Variables Configuration

This file documents the available repository variables and secrets for the GitHub Actions deployment workflow.

## Required GitHub Secrets

### SERVER_SSH_KEY

The SSH private key used to connect to your server for deployment.

**Setup:**

1. Generate an SSH key pair (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "github-actions@yourdomain.com" -f ~/.ssh/foundry_deploy
   ```
2. Copy the public key to your server:
   ```bash
   ssh-copy-id -i ~/.ssh/foundry_deploy.pub user@your-server
   ```
3. Add the private key to GitHub:
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `SERVER_SSH_KEY`
   - Value: Paste the entire content of your private key file

**Security Notes:**

- Use a dedicated key for deployments, not your personal key
- Consider using different keys for different environments
- Regularly rotate your deployment keys
- Never commit private keys to version control

### SUDO_ACCESS_USER (Variable or Secret)

The username of a user with passwordless sudo access on the server. This user is used for system-level operations (installing packages, configuring services, etc.).

**Requirements:**

- Must have passwordless sudo access (e.g., `ubuntu` user on Ubuntu, or `root`)
- Must have SSH access with the `SERVER_SSH_KEY`

**Setup:**
Add as either a variable or secret:

- Go to repository Settings → Secrets and variables → Actions
- For Variable: Click "Variables" tab → "New repository variable"
- For Secret (more secure): Click "Secrets" tab → "New repository secret"
- Name: `SUDO_ACCESS_USER`
- Value: Username (e.g., `ubuntu`, `root`, or your sudo user)

**Note:** This is required when using:

- "Full Development Server" profile
- "System Services Only" profile
- "Custom" profile with any system modules enabled

---

## Optional Repository Variables

All variables have sensible defaults and are optional. Configure them only if you need custom values.

### Configuration Variables

#### NVM_VERSION

- **Description:** Version of Node Version Manager (nvm) to install
- **Default:** `v0.40.3`
- **Example:** `v0.39.0`, `v0.41.0`
- **Use case:** Using a specific nvm version

#### CODE_SERVER_PORT_START

- **Description:** Starting port number for code-server port range scan
- **Default:** `8080`
- **Example:** `9000`
- **Use case:** Custom port range for your infrastructure

#### CODE_SERVER_PORT_END

- **Description:** Ending port number for code-server port range scan
- **Default:** `8100`
- **Example:** `9100`
- **Use case:** Custom port range for your infrastructure

---

## Custom Profile Module Variables

These variables are only used when you select the **"Custom (use repository variables)"** profile. They allow you to enable/disable individual modules.

### System Module Variables

Control which system-level services to install (requires SUDO_ACCESS_USER):

#### SETUP_OPENSSH_UFW

- **Description:** Setup OpenSSH and UFW firewall
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Use case:** Configure firewall and SSH settings

#### SETUP_PACKAGES

- **Description:** Install necessary development packages
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Installs:** git, curl, wget, build-essential, and development libraries

#### SETUP_NGINX

- **Description:** Install and configure Nginx web server
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Use case:** Web server and reverse proxy setup

#### SETUP_CERTBOT

- **Description:** Install Certbot for SSL certificates
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Requires:** snapd to be available on the server

#### SETUP_CODE_SERVER_SYSTEM

- **Description:** Install code-server system-wide
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Use case:** Make code-server available for all users

#### SETUP_POSTGRES

- **Description:** Install and configure PostgreSQL database
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Installs:** PostgreSQL server and client tools

### User Module Variables

Control which user-level tools to install (no sudo required):

#### SETUP_CODE_SERVER_USER

- **Description:** Configure code-server for the target user
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Creates:** User-specific code-server configuration with password

#### SETUP_UV

- **Description:** Install uv Python package manager
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Also installs:** Latest Python version via uv

#### SETUP_NVM

- **Description:** Install nvm Node.js version manager
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Also installs:** Latest Node.js and npm

#### SETUP_REPOS_DIR

- **Description:** Create ~/repos directory for projects
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Creates:** `~/repos` folder in user's home directory

#### SETUP_GIT_SSH

- **Description:** Setup Git configuration and SSH keys
- **Type:** Boolean (`true` or `false`)
- **Default:** `false`
- **Requires:** Git user name and email to be provided in workflow inputs
- **Creates:** ed25519 SSH key pair for Git operations

---

## How to Set Repository Variables

1. Navigate to your repository on GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click the **Variables** tab (or **Secrets** tab for secrets)
4. Click **New repository variable** (or **New repository secret**)
5. Enter the variable/secret name and value
6. Click **Add variable** (or **Add secret**)

---

## Example Custom Profile Configuration

To create a custom setup with only Nginx, PostgreSQL, and user tools:

1. Set these variables in your repository:

   ```
   SETUP_NGINX=true
   SETUP_POSTGRES=true
   SETUP_CODE_SERVER_USER=true
   SETUP_UV=true
   SETUP_REPOS_DIR=true
   ```

2. When running the workflow:
   - Select profile: "Custom (use repository variables)"
   - Fill in other required inputs (server host, target user, etc.)
   - If Git/SSH is enabled, provide Git name and email

3. Only the enabled modules will be installed

---

## Profile vs Variables

**When to use profiles:**

- Most use cases - profiles cover common scenarios
- Quick setup without configuration
- You want all or none of a category

**When to use Custom profile with variables:**

- Unique setups not covered by profiles
- Gradual migrations (add one service at a time)
- Different module combinations across multiple servers
- Fine-grained control over what gets installed
