# GitHub Actions Deployment Guide

This guide explains how to use the GitHub Actions workflow to automatically deploy the Foundry setup scripts to your Ubuntu server with granular control over what gets installed.

## Prerequisites

1. **Ubuntu Server**: Fresh Ubuntu 24.04 server with SSH access
2. **SSH Key Pair**: For connecting to your server
3. **GitHub Repository**: Fork this repository to your own account (required to store secrets)
4. **Sudo User**: A user with passwordless sudo access on the server (for system operations)

## Quick Start

### Step 1: Add SSH Key to GitHub Secrets

1. Generate an SSH key (if needed):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/foundry_setup
   ```

2. Copy public key to your sudo user on the server:

   ```bash
   ssh-copy-id -i ~/.ssh/foundry_setup.pub ubuntu@your-server-ip
   ```

3. Add private key to GitHub:
   - Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
   - Click **New repository secret**
   - Name: `SERVER_SSH_KEY`
   - Value: Paste content of `~/.ssh/foundry_setup` (private key)

### Step 2: Configure SUDO_ACCESS_USER

Add the username of your sudo user:
- Go to: **Settings** → **Secrets and variables** → **Actions** → **Variables** (or **Secrets** for more security)
- Click **New repository variable** (or **New repository secret**)
- Name: `SUDO_ACCESS_USER`
- Value: `ubuntu` (or `root`, or your sudo username)

**Note:** This user must have passwordless sudo access and SSH access with the `SERVER_SSH_KEY`.

### Step 3: (Optional) Configure Repository Variables

See [VARIABLES.md](VARIABLES.md) for available variables like `NVM_VERSION`, `CODE_SERVER_PORT_START`, etc.

### Step 4: Run the Workflow

1. Go to **Actions** tab in your repository
2. Select **Setup Server** workflow
3. Click **Run workflow** (top right)
4. Fill in the form:

   **Required inputs:**
   - **Server host**: Your server IP or hostname
   - **Target user**: The user to setup (will be created if doesn't exist)

   **User creation options (if user doesn't exist):**
   - **Create user if missing**: Check to auto-create the user
   - **Make user sudo**: Check to give the new user passwordless sudo
   - **SSH public key**: Paste SSH public key to allow SSH login for new user

   **System setup modules** (requires SUDO_ACCESS_USER):
   - **Setup OpenSSH and UFW**: Configure firewall and SSH
   - **Setup packages**: Install development packages
   - **Setup Nginx**: Install and configure Nginx
   - **Setup Certbot**: Install Certbot for SSL certificates
   - **Setup code-server (system)**: Install code-server system-wide
   - **Setup PostgreSQL**: Install PostgreSQL database

   **User setup modules** (runs as target user):
   - **Setup code-server (user)**: Configure code-server for the user
   - **Setup uv**: Install uv Python package manager
   - **Setup nvm**: Install nvm Node.js version manager
   - **Setup repos directory**: Create ~/repos directory
   - **Setup Git and SSH**: Configure git and generate SSH keys
   - **Git user name**: Required if setting up Git
   - **Git user email**: Required if setting up Git

5. Click **Run workflow**

### Step 5: Monitor Deployment

- Watch the workflow execution in real-time
- Check for any errors in the logs
- Review the post-setup instructions in the workflow output

### Step 6: Review Outputs

After the workflow completes:

- **View the Setup Summary**: Check the workflow run's Summary tab for:
  - Code-server port and password (if configured)
  - Direct access URL
  - Generated SSH public key (if configured)
  - Important post-setup notes
- **Review Run Logs**: Check the detailed logs for any warnings or additional information

## Deployment Scenarios

### Scenario 1: Full Server Setup for New User

Setup everything for a brand new user on a fresh server:

```yaml
Server host: 192.168.1.100
Target user: developer
Create user if missing: ✓
Make user sudo: ✓
SSH public key: <paste your public key>

# System modules (all checked)
Setup OpenSSH and UFW: ✓
Setup packages: ✓
Setup Nginx: ✓
Setup Certbot: ✓
Setup code-server (system): ✓
Setup PostgreSQL: ✓

# User modules (all checked)
Setup code-server (user): ✓
Setup uv: ✓
Setup nvm: ✓
Setup repos directory: ✓
Setup Git and SSH: ✓
Git user name: John Doe
Git user email: john@example.com
```

### Scenario 2: Only User Setup for Existing User

Just configure development tools for an existing user:

```yaml
Server host: 192.168.1.100
Target user: existinguser

# User modules only
Setup code-server (user): ✓
Setup uv: ✓
Setup nvm: ✓
Setup repos directory: ✓
Setup Git and SSH: ✓
Git user name: Jane Smith
Git user email: jane@example.com
```

### Scenario 3: Only System Setup

Install system-wide tools without user-specific configuration:

```yaml
Server host: 192.168.1.100
Target user: ubuntu  # or any existing user

# System modules only
Setup OpenSSH and UFW: ✓
Setup packages: ✓
Setup Nginx: ✓
Setup Certbot: ✓
Setup PostgreSQL: ✓
```

### Scenario 4: Add Code-Server to Existing User

Just setup code-server for a user who already has other tools:

```yaml
Server host: 192.168.1.100
Target user: developer

# Only code-server
Setup code-server (user): ✓
```

### Scenario 5: Re-run Setup (Idempotent)

All modules are idempotent - safe to run multiple times. To add a new tool or reconfigure:

```yaml
Server host: 192.168.1.100
Target user: developer

# Only check the new tool you want to add
Setup nvm: ✓  # Adds nvm if not already installed
```

## Understanding the Workflow

### User Management

- **target_user**: The user to configure. If the user doesn't exist and `create_user_if_missing` is true, it will be created.
- **create_user_if_missing**: Automatically create the user if they don't exist
- **make_user_sudo**: When creating a new user, add them to sudo group with passwordless sudo
- **ssh_public_key**: When creating a new user, add this SSH public key to their authorized_keys

### Module Types

**System Modules**: Require `SUDO_ACCESS_USER` to be configured. These install system-wide tools and services:
- Run with sudo privileges
- Installed for all users
- Examples: Nginx, PostgreSQL, system packages

**User Modules**: Run as the target user. These configure user-specific tools:
- No sudo required
- Configured per user
- Examples: code-server config, nvm, uv, Git config

### Idempotency

All modules check if their components are already installed/configured before making changes. This means:
- Safe to run multiple times
- Won't duplicate configurations
- Won't break existing setups
- Can selectively add new modules

## Troubleshooting

### SSH Connection Failed

**Problem:** Workflow fails at "Test SSH Connection" step

**Solutions:**

1. Verify server is reachable: `ping your-server-ip`
2. Check SSH key is correct in GitHub Secrets
3. Verify public key is in the SUDO_ACCESS_USER's `~/.ssh/authorized_keys`
4. Check firewall allows SSH: `sudo ufw status`
5. Verify SSH port (default is 22)

### SUDO_ACCESS_USER Not Set

**Problem:** Error about SUDO_ACCESS_USER being required

**Solutions:**

1. Add `SUDO_ACCESS_USER` as a variable or secret in GitHub repository settings
2. Ensure the value is a valid username with passwordless sudo
3. Or, only use user modules which don't require sudo

### User Creation Failed

**Problem:** Target user creation fails

**Solutions:**

1. Ensure `SUDO_ACCESS_USER` has permissions to create users
2. Check if user already exists: `id username`
3. Verify `create_user_if_missing` is set to true

### Permission Denied

**Problem:** Scripts fail with permission errors

**Solutions:**

1. For system modules: verify `SUDO_ACCESS_USER` has passwordless sudo
2. For user modules: verify target user exists and is accessible
3. Check SSH key has correct permissions

### Module Already Installed

**Problem:** Module reports already installed but configuration is wrong

**Solutions:**

1. Modules are idempotent - they skip if already installed
2. To force reconfiguration, manually uninstall the component first
3. Or modify the script to force reinstallation (not recommended)

## Advanced Usage

### Parallel Deployments

To deploy to multiple servers simultaneously:

1. Trigger the workflow multiple times with different server hosts
2. Each run is independent
3. Monitor all runs in the Actions tab

### Custom Module Combinations

Mix and match modules based on your needs:

- Development server: code-server, nvm, uv, Git
- Web server: Nginx, Certbot, PostgreSQL
- Minimal setup: Just packages and UFW

### Updating Existing Installations

Re-run workflow with specific modules to update:

1. Run with only the module you want to update checked
2. Idempotency ensures safe updates
3. No need to re-run all modules

## Security Best Practices

1. **SSH Keys**: Use dedicated keys for deployments, not your personal keys
2. **Secrets Management**: Use GitHub Secrets for sensitive data
3. **SUDO_ACCESS_USER**: Consider using a dedicated deployment user
4. **Limited Access**: Create deployment users with minimal required permissions
5. **Audit Logs**: Review workflow runs regularly
6. **Branch Protection**: Protect main branch to prevent unauthorized workflow changes
7. **Key Rotation**: Regularly rotate SSH keys and update secrets

## Getting Help

If you encounter issues:

1. Check the workflow logs for detailed error messages
2. Review this guide's troubleshooting section
3. Consult [VARIABLES.md](VARIABLES.md) for configuration options
4. Check the main [README.md](../README.md)
5. Open an issue in the repository with:
   - Workflow run link (sanitized)
   - Error messages
   - Server OS and version
   - Steps to reproduce
