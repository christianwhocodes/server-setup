# 🏗️ Server Bootstrap

Automated, modular, idempotent server setup via GitHub Actions for infrastructure tooling.

## 🧭 Overview

The workflow (`.github/workflows/server-bootstrap.yaml`) connects to your Linux server over SSH using a deployment private key, uploads the bash scripts in `scripts/`, and runs only the modules selected by a profile or by custom repository variables.

All scripts are idempotent: safe to re-run; they skip work when already satisfied.

---

## 🚀 Quick Start

1. **Fork this repository** to your own GitHub account (required to add Secrets/Variables).
2. **Add repository Secrets**: `SERVER_SSH_KEY`, `SUDO_ACCESS_USER`.
3. **(Optional)** Add Variables: `NVM_VERSION` and/or any `SETUP_*` for the Custom profile.
4. **Run the workflow**: Actions → Server Bootstrap → choose a profile and inputs.

---

## ✅ Prerequisites

- Ubuntu server (tested on 24.04)
- Existing sudo user with passwordless sudo (for system modules)
- SSH access using the deployment key's public part
- Forked repository to add Secrets/Variables

---

## 🔐 Required Secrets

Add these in **Settings** → **Secrets and variables** → **Actions** → **Secrets** tab. Click **New repository secret**.

### SERVER_SSH_KEY

Private SSH key used by the workflow runner to connect to the server. The corresponding public key must be present in `~/.ssh/authorized_keys` for `SUDO_ACCESS_USER` (and any other target you connect as).

**Setup:**

- Paste full private key content (no passphrase recommended for automation).
- Ensure its public key is in `~/.ssh/authorized_keys` of the sudo access user.

### SUDO_ACCESS_USER

Existing user on the server with passwordless sudo (`NOPASSWD:ALL`). Used whenever system modules are executed (package installs, service management). Must be reachable via `SERVER_SSH_KEY`.

**Example:** `ubuntu`, `root`, or a dedicated deploy user with passwordless sudo.

---

## ⚙️ Optional Variables

Add these in **Settings** → **Secrets and variables** → **Actions** → **Variables** tab if you need overrides.

| Variable    | Default | Description                    |
| ----------- | ------- | ------------------------------ |
| NVM_VERSION | v0.40.4 | nvm tag used by install script |

### Custom Profile Module Variables

Only evaluated when `setup_profile == "Custom (use repository variables)"`. Each must be set to literal string `"true"` or `"false"` (GitHub stores them as strings).

**System** (run via `SUDO_ACCESS_USER`):

- `SETUP_OPENSSH_UFW`
- `SETUP_PACKAGES`
- `SETUP_NGINX`
- `SETUP_CERTBOT`
- `SETUP_POSTGRES`

**User** (run as `target_user`):

- `SETUP_UV`
- `SETUP_NVM`
- `SETUP_REPOS_DIR`
- `SETUP_GIT_SSH`

---

## 🎛️ Setup Profiles

Select one profile when dispatching the workflow:

### 1. Full Development Server

System modules: OpenSSH/UFW, Packages, Nginx, Certbot, PostgreSQL  
User modules: uv, nvm, repos directory, Git + SSH key

**Use case:** Complete server bootstrap with all tools

### 2. System Services Only

System modules only (OpenSSH/UFW, Packages, Nginx, Certbot, PostgreSQL)

**Use case:** Infrastructure setup without user development tools

### 3. User Tools Only

User modules only (uv, nvm, repos directory, Git + SSH key)

**Use case:** Add dev tools to existing user without system changes

### 4. Custom (use repository variables)

Boolean repository variables (`SETUP_*`) decide which modules run.

**Use case:** Fine-grained control over individual modules

---

## 🧩 Workflow Inputs

When dispatching the workflow, you'll be prompted for these inputs:

| Input          | Required | Default | Description                                                                                                                                                                                                          |
| -------------- | -------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| server_host    | Yes      | -       | Server IP or hostname                                                                                                                                                                                                |
| server_port    | No       | 22      | SSH port                                                                                                                                                                                                             |
| target_user    | Yes      | -       | The Linux user to configure on the server. This is the user who will have dev tools installed (uv, nvm, repos, Git/SSH). If the user doesn't exist, it will be created automatically. User modules run as this user. |
| make_user_sudo | No       | false   | Gives target user passwordless sudo if true                                                                                                                                                                          |
| ssh_public_key | No       | -       | Added to target user's authorized_keys (optional)                                                                                                                                                                    |
| setup_profile  | Yes      | -       | One of the four profiles                                                                                                                                                                                             |
| git_user_name  | No       | -       | Required if Git/SSH module runs                                                                                                                                                                                      |
| git_user_email | No       | -       | Required if Git/SSH module runs                                                                                                                                                                                      |
| dry_run        | No       | false   | Dry run mode - simulates execution without making actual changes. Useful for validating configuration and logic before affecting the server.                                                                         |

**Note:** There is no "create user" toggle—creation is automatic if the user does not exist.

---

## 🧱 Available Modules

### System Modules (require sudo)

#### 🔒 OpenSSH/UFW

**Script:** `openssh-ufw.sh`  
**What it does:**

- Adds `OpenSSH` allow rule if absent
- Only enables UFW after confirming the rule, mitigating lockout risk
- Skips enable if rule confirmation fails

#### 🛠️ Packages

**Script:** `packages.sh`  
**What it does:**

- Installs build/development libraries: git, curl, toolchains, SQLite, Pandoc, TeX, snapd, etc.

#### 🌐 Nginx

**Script:** `nginx.sh`  
**What it does:**

- Installs and starts Nginx service
- Creates `/etc/nginx/snippets/port-proxy.conf` (expects `$upstream_port` variable)
- Does NOT create server blocks—you must add your own site config

**Example server block:**

```nginx
server {
  listen 80;
  server_name your.domain;
  set $upstream_port 8080;  # match your application port
  include /etc/nginx/snippets/port-proxy.conf;
}
```

Then run: `sudo nginx -t && sudo systemctl reload nginx`

#### 🔏 Certbot

**Script:** `certbot.sh`  
**What it does:**

- Installs Certbot via snap

**Manual follow-up:** Run `sudo certbot certonly --nginx -d your.domain` after setting up domain + server block.

#### 🐘 PostgreSQL

**Script:** `postgres.sh`  
**What it does:**

- Installs PostgreSQL server + contrib
- Enables and starts service
- Does NOT create databases or roles—manual configuration required

**Manual follow-up:** Create roles/databases with `sudo -iu postgres psql`

### User Modules (non-sudo)

#### 🐍 uv

**Script:** `uv.sh`  
**What it does:**

- Installs uv Python package manager
- If Python missing, installs via `uv python install`

#### 📗 nvm

**Script:** `nvm.sh`  
**What it does:**

- Installs specified nvm version
- Installs latest Node.js
- Updates npm

#### 📁 Repos Directory

**Script:** `repos.sh`  
**What it does:**

- Ensures `~/repos` directory exists

#### 🔑 Git/SSH

**Script:** `git-ssh.sh`  
**What it does:**

- Sets global git config (overwrites previous name/email values)
- Generates `~/.ssh/id_ed25519` key pair if absent
- Public key surfaced in workflow summary for adding to hosting platforms

**Requirements:** `git_user_name` and `git_user_email` must be provided in workflow inputs.

---

## 📜 Module Summary Table

| Variable          | Script(s)      | Notes                                                       |
| ----------------- | -------------- | ----------------------------------------------------------- |
| SETUP_OPENSSH_UFW | openssh-ufw.sh | Adds OpenSSH allow rule; enables UFW only if rule confirmed |
| SETUP_PACKAGES    | packages.sh    | Development toolchain & libs including snapd                |
| SETUP_NGINX       | nginx.sh       | Installs, enables service; creates proxy snippet only       |
| SETUP_CERTBOT     | certbot.sh     | Installs via snap (snapd provided by packages.sh)           |
| SETUP_POSTGRES    | postgres.sh    | Enables & starts service                                    |
| SETUP_UV          | uv.sh          | Installs uv + Python if missing                             |
| SETUP_NVM         | nvm.sh         | Installs Node + updates npm                                 |
| SETUP_REPOS_DIR   | repos.sh       | Ensures ~/repos                                             |
| SETUP_GIT_SSH     | git-ssh.sh     | Needs workflow inputs git_user_name/email                   |

---

## 🔄 How It Works (Execution Flow)

1. **Repository checkout** - Scripts become available locally on runner
2. **Module determination** - Based on profile or custom variables
3. **Input validation** - Checks Git info if needed; verifies SUDO_ACCESS_USER for system modules
4. **SSH key provisioning** - Sets up runner authentication
5. **SSH connectivity test** - As sudo access user or target user depending on module mix
6. **Target user creation/update** - Automatically creates user if missing
7. **Script upload** - Via `scp` to `/tmp/` on remote server
8. **Module execution** - Conditionally runs each selected module
9. **Credential retrieval** - Fetches SSH public key if Git/SSH module ran
10. **Summary output** - Displays configuration details
11. **Cleanup** - Removes remote scripts and local SSH key

---

## ♻️ Idempotency

All scripts are designed to be safe to re-run:

- **Variables only control whether a script runs** - Each script internally checks state
- **Binary presence** - Skips installation if already exists
- **Service state** - Only starts/enables if needed
- **Directory/key existence** - Creates only if absent

Re-running with `"true"` does not break prior setup. Safe to add modules later by re-running workflow with Custom profile and enabling only new modules.

### Idempotency Examples

- Add PostgreSQL later: Set `SETUP_POSTGRES=true` (custom profile) → Only PostgreSQL script runs
- Profile switch: Include previously omitted modules → Already installed modules detected and skipped

---

## � Dry Run Mode

The workflow includes a **dry run mode** that simulates execution without making any actual changes to the server. This is useful for:

- **Validation:** Verify configuration before running against production/development servers
- **Debugging:** Test workflow logic without affecting server state
- **Documentation:** Generate execution plans for review
- **Training:** Understand what the workflow will do without risk

### How to Use Dry Run

Set the `dry_run` input to `true` when dispatching the workflow. The workflow will:

- ✅ Connect to the server via SSH
- ✅ Check current state (users, installed packages, etc.)
- ✅ Display what actions would be taken
- ❌ Not create users, install packages, or modify any files
- ❌ Not enable services or change configurations

All steps will output `[DRY RUN] Would...` messages instead of performing actual operations.

### Example Output

```
[DRY RUN] Would create user: developer
[DRY RUN] Would install necessary packages
[DRY RUN] Would setup Nginx
[DRY RUN] Would setup uv
```

---

## �📚 Common Use Cases

### 1. New Full Development Server

**Profile:** Full Development Server  
**Inputs:** Provide git_user_name/email  
**Outcome:** Complete system + user environment with all tools

### 2. Infrastructure Only

**Profile:** System Services Only  
**Outcome:** Services installed; no user toolchain

### 3. Add Dev Tools to Existing User

**Profile:** User Tools Only  
**Outcome:** uv, nvm, repos, Git/SSH installed; no system changes

### 4. Incremental Module Addition

**Profile:** Custom  
**Variables:** Set specific `SETUP_*` variables (e.g., `SETUP_POSTGRES=true`)  
**Outcome:** Only specified modules run; existing setup untouched

### 5. Add Just nvm Later

**Profile:** Custom  
**Variables:** `SETUP_NVM=true`  
**Outcome:** nvm added; prior modules untouched

---

## 🧪 Example Custom Configuration

Enable only Nginx + nvm:

```
SETUP_NGINX=true
SETUP_NVM=true
```

Then dispatch workflow with profile: `Custom (use repository variables)`.

---

## 🔑 Credential Retrieval

After successful setup, if Git/SSH module runs, the workflow fetches:

- **SSH public key** (`id_ed25519.pub`) displayed in workflow summary for adding to hosting services (GitHub, GitLab, etc.)

The private key remains securely on the server at `~/.ssh/id_ed25519`.

---

## 📝 When Git Inputs Are Required

`git_user_name` and `git_user_email` must be provided if:

- Profile includes Git/SSH module (Full Development Server, User Tools Only)
- Custom profile sets `SETUP_GIT_SSH=true`

---

## 🧪 Troubleshooting

### Common Issues

| Issue                                 | Solution                                                                                |
| ------------------------------------- | --------------------------------------------------------------------------------------- |
| SSH connection fails                  | Verify host, port, key format (`ssh -i key user@host`), firewall rule, server reachable |
| Missing SUDO_ACCESS_USER error        | Add secret; verify passwordless sudo exists                                             |
| Certbot failure (snap not found)      | This shouldn't happen anymore—packages.sh now installs snapd                            |
| Git module error (missing name/email) | Provide both inputs when profile includes Git/SSH                                       |
| UFW enable skipped                    | Ensure OpenSSH rule added; rerun script                                                 |

### Getting Help

Open an issue with:

- Workflow run URL
- Relevant log excerpts
- Server OS/version
- Module(s) failing
- Steps attempted

---

## 📌 Manual Follow-ups After Run

- **Nginx:** Create server block referencing snippets
- **Certbot:** Run `sudo certbot certonly --nginx -d your.domain` (after domain + server block configured)
- **SSH Key:** Add retrieved public key to Git hosting provider
- **PostgreSQL:** Create roles/databases (`sudo -iu postgres psql`)
- **Security:** Rotate generated SSH keys as needed

---

## 🛡️ Security Considerations

- **Passwordless sudo** is restricted to `SUDO_ACCESS_USER` and optionally `target_user` if `make_user_sudo=true`
- **Deployment SSH key** should be dedicated; rotate periodically
- **Generated Git SSH key** remains on server (private part not exfiltrated)
- **Limit** the number of users with passwordless sudo
- **Audit** `~/.ssh/authorized_keys` regularly
- **Review** workflow run logs for unexpected warnings
- **Limit** `SUDO_ACCESS_USER` privileges to what is necessary
- **Rotate** `SERVER_SSH_KEY` regularly

---

## 🧱 Extending the Workflow

To add new scripts:

1. Create script under `scripts/` following existing pattern:
   - Check existence first
   - Exit early on success
   - Echo status clearly
2. Add corresponding variable in workflow logic (e.g., `SETUP_YOUR_MODULE`)
3. Add step in workflow YAML with conditional execution

---

## 🗂️ Repository Structure

```
.github/
  workflows/
    server-bootstrap.yaml
scripts/
  certbot.sh
  git-ssh.sh
  nginx.sh
  nvm.sh
  openssh-ufw.sh
  packages.sh
  postgres.sh
  repos.sh
  uv.sh
LICENSE
README.md
TODO.md
```

---

## 📁 Reference: Scripts

Located in `scripts/`:

**System (require sudo):**

- `openssh-ufw.sh` - Firewall configuration
- `packages.sh` - Development packages + snapd
- `nginx.sh` - Web server
- `certbot.sh` - SSL certificates
- `postgres.sh` - Database server

**User (non-sudo):**

- `uv.sh` - Python package manager
- `nvm.sh` - Node version manager
- `repos.sh` - Repos directory
- `git-ssh.sh` - Git config + SSH key generation

---

## 📄 License

MIT
