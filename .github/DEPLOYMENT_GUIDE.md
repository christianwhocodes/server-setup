# GitHub Actions Deployment Guide

This guide explains how to use the GitHub Actions workflow to automatically deploy the Foundry setup scripts to your Ubuntu server.

## Prerequisites

1. **Ubuntu Server**: Fresh Ubuntu 24.04 server with SSH access
2. **SSH Key Pair**: For connecting to your server
3. **GitHub Repository**: This repository (forked or original)
4. **Server Prepared**:
   - OpenSSH installed and running
   - Firewall configured to allow SSH
   - For system setup: root access or sudo user
   - For user setup: user account created

## Quick Start

### Step 1: Add SSH Key to GitHub Secrets

1. Generate an SSH key (if needed):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/foundry_deploy
   ```

2. Copy public key to server:

   ```bash
   ssh-copy-id -i ~/.ssh/foundry_deploy.pub root@your-server-ip
   ```

3. Add private key to GitHub:
   - Go to: **Settings** → **Secrets and variables** → **Actions** → **Secrets**
   - Click **New repository secret**
   - Name: `SERVER_SSH_KEY`
   - Value: Paste content of `~/.ssh/foundry_deploy` (private key)

### Step 2: (Optional) Configure Repository Variables

See [VARIABLES.md](VARIABLES.md) for available variables.

### Step 3: Run the Workflow

1. Go to **Actions** tab in your repository
2. Select **Deploy Server Setup** workflow
3. Click **Run workflow** (top right)
4. Fill in the form:

   **For System Setup:**

   - Setup type: `system` or `both`
   - Server host: `your-server-ip`
   - Server user: `root`
   - Server port: `22` (or your custom SSH port)

   **For User Setup:**

   - Setup type: `user` or `both`
   - Server host: `your-server-ip`
   - Server user: `developer` (or your username)
   - Server port: `22`
   - Git user name: `Your Name`
   - Git user email: `your@email.com`

5. Click **Run workflow**

### Step 4: Monitor Deployment

- Watch the workflow execution in real-time
- Check for any errors in the logs
- Review the post-setup instructions in the workflow output

### Step 5: Post-Deployment

After user setup, you need to manually:

1. **Enable code-server** (requires sudo):

   ```bash
   ssh root@your-server 'systemctl enable --now code-server@developer'
   ```

2. **Get code-server credentials**:

   ```bash
   ssh developer@your-server 'cat ~/.config/code-server/config.yaml'
   ```

3. **Get SSH public key** (for GitHub/GitLab):

   ```bash
   ssh developer@your-server 'cat ~/.ssh/id_ed25519.pub'
   ```

4. **Restart the session**:
   ```bash
   ssh developer@your-server 'source ~/.bashrc'
   ```

## Deployment Scenarios

### Scenario 1: Brand New Server

Setup both system and user in one run:

```yaml
Setup type: both
Server host: 192.168.1.100
Server user: root
Git user name: John Doe
Git user email: john@example.com
```

**Note:** When using `both`, the workflow runs system setup first, then user setup. Make sure the server user specified is root or has sudo privileges.

### Scenario 2: Add New User to Existing Server

System already configured, just add a new user:

```yaml
Setup type: user
Server host: 192.168.1.100
Server user: newuser
Git user name: Jane Smith
Git user email: jane@example.com
```

### Scenario 3: Reconfigure System

Re-run system setup (safe to run multiple times):

```yaml
Setup type: system
Server host: 192.168.1.100
Server user: root
```

### Scenario 4: Multiple Servers

Run the workflow multiple times with different server IPs to deploy to multiple servers.

## Troubleshooting

### SSH Connection Failed

**Problem:** Workflow fails at "Test SSH Connection" step

**Solutions:**

1. Verify server is reachable: `ping your-server-ip`
2. Check SSH key is correct in GitHub Secrets
3. Verify public key is in server's `~/.ssh/authorized_keys`
4. Check firewall allows SSH: `sudo ufw status`
5. Verify SSH port (default is 22)

### Permission Denied

**Problem:** Scripts fail with permission errors

**Solutions:**

1. For system setup: use `root` user or user with sudo privileges
2. Verify SSH key has correct permissions
3. Check user exists on server: `id username`

### Git Configuration Missing

**Problem:** User setup fails asking for git configuration

**Solutions:**

1. Ensure `git_user_name` and `git_user_email` are provided in workflow inputs
2. These are required for user setup

### Port Already in Use

**Problem:** Code-server setup fails finding available port

**Solutions:**

1. Configure custom port range with repository variables:
   - `CODE_SERVER_PORT_START`
   - `CODE_SERVER_PORT_END`
2. Check what's using ports: `sudo ss -tulpn | grep :8080`

### Script Download Failed

**Problem:** Cannot download scripts from GitHub

**Solutions:**

1. Ensure the repository/commit of the current workflow run is accessible from your server
2. Verify server has internet access: `curl -I https://github.com`
3. Check GitHub is accessible from your server

## Advanced Usage

### Custom Repository Branch

To test changes on a feature branch, run the workflow from that branch; it will use that commit automatically.

### Parallel Deployments

To deploy to multiple servers simultaneously:

1. Trigger the workflow multiple times
2. Each run is independent
3. Monitor all runs in the Actions tab

### Scheduled Deployments

Add a schedule trigger to the workflow file:

```yaml
on:
  workflow_dispatch:
    # ... existing inputs
  schedule:
    - cron: "0 2 * * 0" # Run every Sunday at 2 AM UTC
```

## Security Best Practices

1. **SSH Keys**: Use dedicated keys for deployments, not your personal keys
2. **Secrets Rotation**: Regularly rotate SSH keys
3. **Limited Access**: Create dedicated deployment users with minimal permissions
4. **Audit Logs**: Review workflow runs regularly
5. **Branch Protection**: Protect main branch to prevent unauthorized workflow changes
6. **Key Management**: Never commit private keys to the repository

## Getting Help

If you encounter issues:

1. Check the workflow logs for detailed error messages
2. Review this guide's troubleshooting section
3. Consult the main [README.md](../README.md)
4. Open an issue in the repository with:
   - Workflow run link
   - Error messages (sanitize any sensitive information)
   - Server OS and version
   - Steps to reproduce
