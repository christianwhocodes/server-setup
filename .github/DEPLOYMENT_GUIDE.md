# GitHub Actions Deployment Guide

This guide explains how to use the GitHub Actions workflow to automatically deploy the Foundry setup scripts to your Ubuntu server with granular control over what gets installed.

## Prerequisites

1. **Ubuntu Server**: Fresh Ubuntu 24.04 server with SSH access
2. **SSH Key Pair**: For connecting to your server
3. **GitHub Repository**: Fork this repository to your own account (required to store secrets)
4. **Sudo User**: A user with passwordless sudo access on the server (for system operations)

## Quick Start

### Step 1: Ensure SSH Access to Server

When creating your server VM (e.g., DigitalOcean Droplet, AWS EC2, or other cloud provider):

1. **During VM provisioning**: Add your SSH public key
   - Most cloud providers have a section to add SSH keys during VM creation
   - The key will be added to the default sudo user (typically `ubuntu` or `root`)
   - Save the corresponding private key securely on your local machine

2. **Verify SSH access** (optional but recommended):
   ```bash
   ssh -i /path/to/your/private-key ubuntu@your-server-ip
   ```

If you can successfully SSH into the server, you're ready to proceed.

### Step 2: Add Private Key to GitHub Secrets

- Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
- Click **New repository secret**
- Name: `SERVER_SSH_KEY`
- Value: Paste the **entire content** of `~/.ssh/foundry_deploy` (the private key file)

### Step 2: Add Private Key to GitHub Secrets

Add the SSH private key that has access to your server:

- Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
- Click **New repository secret**
- Name: `SERVER_SSH_KEY`
- Value: Paste the **entire content** of your private key file (the one configured during VM creation)

**Security Notes:**

- Use a dedicated deployment key when possible
- Never commit private keys to version control
- Use passphrase-free keys for automation (or handle passphrases appropriately)

### Step 3: Configure SUDO_ACCESS_USER

Add the username of your sudo user as a secret:

- Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
- Click **New repository secret**
- Name: `SUDO_ACCESS_USER`
- Value: `ubuntu` (or `root`, or your sudo username)

**Important:** This user must:

- Already exist on the server
- Have passwordless sudo access
- Have SSH access with the `SERVER_SSH_KEY` you configured in Step 1

### Step 3: Configure SUDO_ACCESS_USER

Add the username of your sudo user as a secret:

- Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
- Click **New repository secret**
- Name: `SUDO_ACCESS_USER`
- Value: `ubuntu` (or `root`, or whatever sudo user was configured during VM creation)

**Important:** This user must:

- Already exist on the server
- Have passwordless sudo access
- Have SSH access with the `SERVER_SSH_KEY` private key you added in Step 2

### Step 4: (Optional) Configure Repository Variables

See [VARIABLES.md](VARIABLES.md) for available variables like `NVM_VERSION`, `CODE_SERVER_PORT_START`, etc.

### Step 4: (Optional) Configure Repository Variables

See [VARIABLES.md](VARIABLES.md) for available variables like `NVM_VERSION`, `CODE_SERVER_PORT_START`, etc.

### Step 5: Run the Workflow

1. Go to **Actions** tab in your repository
2. Select **Setup Server** workflow
3. Click **Run workflow** (top right)
4. Fill in the form:

   **Required inputs:**
   - **Server host**: Your server IP or hostname
   - **Server port**: SSH port (default: 22)
   - **Target user**: The user to setup (will be created if doesn't exist)
   - **Setup profile**: Choose from dropdown:
     - **Full Development Server** - Complete setup with all modules
     - **System Services Only** - Infrastructure only (Nginx, PostgreSQL, etc.)
     - **User Tools Only** - Development tools for a specific user
     - **Custom (use repository variables)** - Fine-grained control via variables

   **User creation options (if user doesn't exist):**
   - **Create user if missing**: Check to auto-create the user
   - **Make user sudo**: Check to give the new user passwordless sudo
   - **SSH public key**: Paste SSH public key to allow SSH login for new user (this is different from `SERVER_SSH_KEY`)

   **Git configuration (required for profiles with user tools):**
   - **Git user name**: Required if Git/SSH setup is enabled in the selected profile
   - **Git user email**: Required if Git/SSH setup is enabled in the selected profile

5. Click **Run workflow**

### Step 5: Run the Workflow

1. Go to **Actions** tab in your repository
2. Select **Setup Server** workflow
3. Click **Run workflow** (top right)
4. Fill in the form:

   **Required inputs:**
   - **Server host**: Your server IP or hostname
   - **Server port**: SSH port (default: 22)
   - **Target user**: The user to setup (will be created if doesn't exist)
   - **Setup profile**: Choose from dropdown:
     - **Full Development Server** - Complete setup with all modules
     - **System Services Only** - Infrastructure only (Nginx, PostgreSQL, etc.)
     - **User Tools Only** - Development tools for a specific user
     - **Custom (use repository variables)** - Fine-grained control via variables

   **User creation options (if user doesn't exist):**
   - **Create user if missing**: Check to auto-create the user
   - **Make user sudo**: Check to give the new user passwordless sudo
   - **SSH public key**: Paste SSH public key to allow SSH login for new user (this is different from `SERVER_SSH_KEY`)

   **Git configuration (required for profiles with user tools):**
   - **Git user name**: Required if Git/SSH setup is enabled in the selected profile
   - **Git user email**: Required if Git/SSH setup is enabled in the selected profile

5. Click **Run workflow**

### Step 6: Monitor Deployment

- Watch the workflow execution in real-time
- Check for any errors in the logs
- Review the post-setup instructions in the workflow output

### Step 6: Monitor Deployment

- Watch the workflow execution in real-time
- Check for any errors in the logs
- Review the post-setup instructions in the workflow output

### Step 7: Review Outputs

After the workflow completes:

- **View the Setup Summary**: Check the workflow run's Summary tab for:
  - Code-server port and password (if configured)
  - Direct access URL
  - Generated SSH public key (if configured)
  - Important post-setup notes
- **Review Run Logs**: Check the detailed logs for any warnings or additional information

## Understanding User Management

This is a common source of confusion, so let's clarify:

### Two Types of Users

1. **SUDO_ACCESS_USER** (GitHub Secret)
   - Purpose: Execute system-level operations
   - Requirements:
     - Must already exist on the server
     - Must have passwordless sudo access
     - Must have SSH access with `SERVER_SSH_KEY`
   - Examples: `ubuntu`, `root`, `admin`
   - Used for: Installing packages, configuring Nginx, PostgreSQL, etc.

2. **target_user** (Workflow Input)
   - Purpose: The user you want to configure with dev tools
   - Can be:
     - An existing user (like `SUDO_ACCESS_USER`)
     - A new user to be created
   - Used for: uv, nvm, Git setup, etc.

### SSH Key Confusion Explained

- **SERVER_SSH_KEY** (GitHub Secret):
  - Used by GitHub Actions to connect to the server
  - Private key stored in GitHub Secrets
  - Public key must be in `SUDO_ACCESS_USER`'s `~/.ssh/authorized_keys`
  - Purpose: Automation access

- **ssh_public_key** (Workflow Input):
  - Only used when creating a new `target_user`
  - Your personal/team SSH public key
  - Allows human users to SSH into the new user account
  - Purpose: Human access to the new user

### Common Scenarios

**Scenario A: Setup everything as existing ubuntu user**

- SUDO_ACCESS_USER: `ubuntu`
- target_user: `ubuntu`
- Create user: ❌ No
- Result: Ubuntu user gets all tools installed

**Scenario B: Create new developer user**

- SUDO_ACCESS_USER: `ubuntu`
- target_user: `developer`
- Create user: ✅ Yes
- ssh_public_key: `ssh-ed25519 AAAA... developer@laptop`
- Result: New `developer` user created, ubuntu user still used for system operations

**Scenario C: User-only setup on existing server**

- SUDO_ACCESS_USER: (not needed)
- target_user: `developer`
- System modules: ❌ None
- User modules: ✅ Selected
- Result: Only user-level tools configured

## Deployment Scenarios

### Scenario 1: Full Server Setup for New User

Setup everything for a brand new user on a fresh server:

```yaml
Server host: 192.168.1.100
Target user: developer
Create user if missing: ✓
Make user sudo: ✓
SSH public key: <paste your personal public key>
Setup profile: Full Development Server

Git user name: John Doe
Git user email: john@example.com
```

**What happens:**

- All system modules installed (OpenSSH/UFW, packages, Nginx, Certbot, code-server, PostgreSQL)
- All user modules configured (uv, nvm, repos, Git/SSH)
- Code-server config created with secure permissions
- Service enabled as `code-server@developer`

**Note:** Git credentials are only required because this profile includes Git/SSH setup.

### Scenario 2: Only User Setup for Existing User

Just configure development tools for an existing user:

```yaml
Server host: 192.168.1.100
Target user: existinguser
Setup profile: User Tools Only

Git user name: Jane Smith
Git user email: jane@example.com
```

**What happens:**

- Only user modules: uv, nvm, repos, Git/SSH
- No system changes
- No sudo required (unless target user doesn't exist)

**Note:** Git credentials are only required because Git/SSH setup is selected.

### Scenario 3: Only System Setup

Install system-wide tools without user-specific configuration:

```yaml
Server host: 192.168.1.100
Target user: ubuntu # or any existing user
Setup profile: System Services Only
```

**What happens:**

- System modules: OpenSSH/UFW, packages, Nginx, Certbot, code-server (system install + user config for ubuntu), PostgreSQL
- Code-server configured for the specified target user
- No other user-specific tools installed

### Scenario 4: Add Single Module Using Custom Profile

Just add nvm to an existing user who already has other tools:

1. Set repository variable: `SETUP_NVM=true`
2. Run workflow:

```yaml
Server host: 192.168.1.100
Target user: developer
Setup profile: Custom (use repository variables)
```

**What happens:**

- Only nvm is installed
- All other existing setups remain unchanged
- Idempotent - safe to run

### Scenario 5: Re-run Setup (Idempotent)

All modules are idempotent - safe to run multiple times. To add a new tool or reconfigure:

```yaml
Server host: 192.168.1.100
Target user: developer
Setup profile: Custom (use repository variables)
# Set SETUP_POSTGRES=true in repository variables
```

**What happens:**

- Only PostgreSQL is added
- Existing tools (nvm, uv, etc.) are detected and skipped
- No duplicate configurations

## Understanding the Workflow

### Setup Profiles

The workflow uses **profiles** to simplify configuration:

1. **Full Development Server**
   - All system modules: OpenSSH/UFW, Packages, Nginx, Certbot, Code-server, PostgreSQL
   - All user modules: uv, nvm, repos, Git/SSH
   - Requires: SUDO_ACCESS_USER, Git configuration

2. **System Services Only**
   - All system modules only (including code-server for target user)
   - No additional user modules
   - Requires: SUDO_ACCESS_USER

3. **User Tools Only**
   - All user modules only
   - No system modules
   - Requires: Git configuration
   - Does NOT require SUDO_ACCESS_USER

4. **Custom (use repository variables)**
   - Uses repository variables to control each module individually
   - Variables: `SETUP_OPENSSH_UFW`, `SETUP_PACKAGES`, `SETUP_NGINX`, etc.
   - See [VARIABLES.md](VARIABLES.md) for full list

### Module Types and Scripts

**System Modules**: Require `SUDO_ACCESS_USER` to be configured:

| Module        | Script File              | Description                            |
| ------------- | ------------------------ | -------------------------------------- |
| OpenSSH & UFW | `foundry-openssh-ufw.sh` | Firewall and SSH configuration         |
| Packages      | `foundry-packages.sh`    | Development tools and libraries        |
| Nginx         | `foundry-nginx.sh`       | Web server with proxy configurations   |
| Certbot       | `foundry-certbot.sh`     | SSL certificate management             |
| Code Server   | `foundry-code-server.sh` | System install + user config + service |
| PostgreSQL    | `foundry-postgres.sh`    | Database server                        |

**User Modules**: Run as the target user:

| Module          | Script File          | Description                       |
| --------------- | -------------------- | --------------------------------- |
| uv              | `foundry-uv.sh`      | Python package manager            |
| nvm             | `foundry-nvm.sh`     | Node.js version manager           |
| Repos Directory | `foundry-repos.sh`   | Creates ~/repos folder            |
| Git & SSH       | `foundry-git-ssh.sh` | Git config and SSH key generation |

### Idempotency

All scripts are designed to be idempotent:

- Check if components are already installed before installing
- Safe to run multiple times
- Won't duplicate configurations
- Won't break existing setups
- Can selectively add new modules

Each script file in `scripts/` can be run independently and multiple times safely.

## Troubleshooting

### SSH Connection Failed

**Problem:** Workflow fails at "Test SSH Connection" step

**Solutions:**

1. Verify server is reachable: `ping your-server-ip`
2. Check SSH key in GitHub Secrets matches the key configured during VM creation
3. Verify the `SUDO_ACCESS_USER` value matches the user that has SSH access on the server
4. Check firewall allows SSH: `sudo ufw status`
5. Verify SSH port (default is 22)
6. Test manually with the same key: `ssh -i /path/to/private-key sudo-user@your-server-ip`
7. If VM was recently created, ensure it's fully booted and SSH service is running

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
4. Check logs for specific error messages

### Permission Denied

**Problem:** Scripts fail with permission errors

**Solutions:**

1. For system modules: verify `SUDO_ACCESS_USER` has passwordless sudo
2. For user modules: verify target user exists and is accessible
3. Check SSH key has correct permissions (600 for private key)
4. Verify the public key is in the correct user's authorized_keys

### Module Already Installed

**Problem:** Module reports already installed but configuration is wrong

**Solutions:**

1. Modules are idempotent - they skip if already installed
2. To force reconfiguration, manually uninstall the component first
3. Check the specific script file in `scripts/` directory for what was detected
4. Review the workflow logs for specific detection logic

### Credential Retrieval Failed

**Problem:** Workflow fails to retrieve code-server password or SSH key

**Solutions:**

1. Check that the code-server setup step completed successfully
2. Verify config files were created: `ls -la ~/.config/code-server/`
3. Check SSH key was generated: `ls -la ~/.ssh/id_ed25519*`
4. Review the "Retrieve setup credentials" step logs
5. Verify permissions on config file allow reading

### Git Configuration Errors

**Problem:** Error about missing git_user_name or git_user_email

**Solutions:**

1. Verify that your selected profile or custom configuration includes Git/SSH setup
2. If Git/SSH setup is enabled, both git_user_name and git_user_email are required
3. If you don't need Git/SSH setup, choose a profile or custom configuration that doesn't include it

### Code-Server Permission Issues

**Problem:** Code-server won't start or config cannot be read

**Solutions:**

1. Check config file exists: `ls -la ~/.config/code-server/config.yaml`
2. Verify permissions allow reading:
   ```bash
   # Should show: drwx------ for directory, owned by target user
   ls -ld ~/.config/code-server/
   # Should show: -rw------- and owned by target user
   ls -l ~/.config/code-server/config.yaml
   ```
3. Check service status: `sudo systemctl status code-server@[target_user]`
4. Review service logs: `sudo journalctl -u code-server@[target_user] -n 50`

## Advanced Usage

### Parallel Deployments

To deploy to multiple servers simultaneously:

1. Trigger the workflow multiple times with different server hosts
2. Each run is independent
3. Monitor all runs in the Actions tab

### Custom Module Combinations

Mix and match modules based on your needs:

- Development server: code-server, uv, nvm, Git
- Web server: Nginx, Certbot, PostgreSQL
- Minimal setup: Just packages and UFW

### Updating Existing Installations

Re-run workflow with specific modules to update:

1. Use Custom profile with only the module you want to update
2. Set repository variable (e.g., `SETUP_NGINX=true`)
3. Run workflow - idempotency ensures safe updates
4. No need to re-run all modules

### Modifying Individual Scripts

Each script in `scripts/` is standalone and can be modified:

1. Edit the specific script file (e.g., `scripts/foundry-nginx.sh`)
2. Commit changes to your fork
3. Re-run the workflow
4. Only that module's script will be updated on the server

## Security Best Practices

1. **SSH Keys**:
   - Use dedicated keys for deployments, not your personal keys
   - Consider using passphrase-protected keys
   - Regularly rotate deployment keys
   - Use different keys for different environments

2. **Secrets Management**:
   - Use GitHub Secrets for sensitive data
   - Never commit private keys or passwords to git
   - Use environment-specific secrets when possible

3. **SUDO_ACCESS_USER**:
   - Consider using a dedicated deployment user
   - Limit sudo permissions where possible
   - Regularly audit sudo access

4. **Limited Access**:
   - Create deployment users with minimal required permissions
   - Use principle of least privilege

5. **Audit Logs**:
   - Review workflow runs regularly
   - Monitor failed authentication attempts on servers
   - Keep server logs for security review

6. **Branch Protection**:
   - Protect main branch to prevent unauthorized workflow changes
   - Require pull request reviews for workflow modifications
   - Require pull request reviews for script changes

7. **Key Rotation**:
   - Regularly rotate SSH keys and update secrets
   - Remove old keys from authorized_keys
   - Update GitHub Secrets after rotation

## Getting Help

If you encounter issues:

1. Check the workflow logs for detailed error messages
2. Review this guide's troubleshooting section
3. Consult [VARIABLES.md](VARIABLES.md) for configuration options
4. Check the individual script files in `scripts/` directory
5. Check the main [README.md](../README.md)
6. Open an issue in the repository with:
   - Workflow run link (sanitized)
   - Error messages
   - Server OS and version
   - Steps to reproduce
   - Which script file is causing issues
