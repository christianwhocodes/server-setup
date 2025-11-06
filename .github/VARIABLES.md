# GitHub Repository Variables Configuration

This file documents the available repository variables for the GitHub Actions deployment workflow.

Note: The workflow always uses the repository and commit of the run. REPO_OWNER, REPO_NAME, and REPO_BRANCH are not read by the workflow and are only shown below for manual setup.

## Required GitHub Secrets

### SERVER_SSH_KEY

The SSH private key used to connect to your server.

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
3. Click the **Variables** tab
4. Click **New repository variable**
5. Enter the variable name and value
6. Click **Add variable**

## Environment Variables for Manual Setup

These variables are for manual script execution only (not used by the GitHub Actions workflow):

```bash
export REPO_OWNER="myusername"
export REPO_NAME="foundry"
export REPO_BRANCH="main"
export GIT_USER_NAME="John Doe"
export GIT_USER_EMAIL="john@example.com"
export NVM_VERSION="v0.40.3"
export CODE_SERVER_PORT_START="9000"
export CODE_SERVER_PORT_END="9100"

# Then run the setup
bash -c "$(curl -sSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}/user/setup.sh)"
```
