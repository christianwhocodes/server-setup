# GitHub Repository Variables Configuration

This file documents the available repository variables and secrets for the GitHub Actions deployment workflow.

## Required GitHub Secrets

### SERVER_SSH_KEY

The SSH private key used to connect to your server for deployment.

**Setup:**

1. Generate an SSH key pair (if you don't have one):

   ```bash
   ssh-keygen -t ed25519 -C "github-actions@yourdomain.com"
   ```

2. Copy the public key to your server:

   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server
   ```

3. Add the private key to GitHub:
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `SERVER_SSH_KEY`
   - Value: Paste the entire content of your private key file

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

**Note:** This is required when using any system setup modules (openssh, packages, nginx, certbot, code-server system-wide, or postgres).

## Optional Repository Variables

All variables have sensible defaults and are optional. Configure them only if you need custom values.

### NVM_VERSION

- **Description:** Version of Node Version Manager (nvm) to install
- **Default:** `v0.40.3`
- **Example:** `v0.39.0`, `v0.41.0`
- **Use case:** Using a specific nvm version

### CODE_SERVER_PORT_START

- **Description:** Starting port number for code-server port range scan
- **Default:** `8080`
- **Example:** `9000`
- **Use case:** Custom port range for your infrastructure

### CODE_SERVER_PORT_END

- **Description:** Ending port number for code-server port range scan
- **Default:** `8100`
- **Example:** `9100`
- **Use case:** Custom port range for your infrastructure

## How to Set Repository Variables

1. Navigate to your repository on GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click the **Variables** tab (or **Secrets** tab for secrets)
4. Click **New repository variable** (or **New repository secret**)
5. Enter the variable/secret name and value
6. Click **Add variable** (or **Add secret**)
