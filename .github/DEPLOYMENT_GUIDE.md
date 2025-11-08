# 🚀 Deployment Guide

How to run the GitHub Actions workflow to configure an Ubuntu server using modular bash scripts.

## ✅ Prerequisites

- Fork this repository to your GitHub account (you need your own copy to add Secrets/Variables).
- Ubuntu server (tested on 24.04)
- Existing sudo user with passwordless sudo (for system modules)
- SSH access using the deployment key’s public part

## 🔐 Secrets Setup

1. SERVER_SSH_KEY
   - Paste full private key content (no passphrase recommended for automation).
   - Ensure its public key is in `~/.ssh/authorized_keys` of the sudo access user.

2. SUDO_ACCESS_USER
   - Username (e.g., `ubuntu`, `root`, or a dedicated deploy user) with passwordless sudo.

## ⚙️ Optional Variables

Define in repository Variables tab if you need overrides:

- NVM_VERSION
- CODE_SERVER_PORT_START
- CODE_SERVER_PORT_END
- (Custom profile only) `SETUP_*` booleans.

See VARIABLES.md for full list.

## 🧩 Workflow Inputs (Run Form)

| Input          | Purpose                                           |
| -------------- | ------------------------------------------------- |
| server_host    | IP or hostname                                    |
| server_port    | SSH port (default 22)                             |
| target_user    | User to configure (auto-created if absent)        |
| make_user_sudo | Grants passwordless sudo to target user if true   |
| ssh_public_key | Added to target user’s authorized_keys (optional) |
| setup_profile  | Selects module set or custom variable mode        |
| git_user_name  | Required if Git/SSH module runs                   |
| git_user_email | Required if Git/SSH module runs                   |

Note: There is no “create user” toggle—creation is automatic if the user does not exist.

## 🔄 Execution Flow

1. Repository checkout (scripts available locally).
2. Module determination based on profile or custom variables.
3. Input validation (Git info if Git/SSH module enabled; presence of SUDO_ACCESS_USER for system modules).
4. SSH key provisioning (runner).
5. SSH connectivity test (as sudo access user or target user depending on module mix).
6. Target user creation/update (always attempts creation if missing).
7. Script upload via `scp` to `/tmp/`.
8. Conditional execution of each selected module.
9. Credential retrieval (code-server port/password, SSH public key) if applicable.
10. Summary output.
11. Remote cleanup (`/tmp/*.sh`) and local key removal.

## 💻 Code-server Steps

1. Install (sudo): system-wide via installation script.
2. Configure (target user): selects free port in given range, generates random password, writes `~/.config/code-server/config.yaml`.
3. Service Enable (sudo): enables and starts `code-server@target_user`.

Credentials (port/password) extracted only after successful configuration.

## 🌐 Nginx Caveat

The script:

- Installs Nginx.
- Creates snippet files (`port-proxy.conf`, `code-server-proxy.conf`).
- Does NOT create or modify a server block. You must add a site config:
  ```
  server {
    listen 80;
    server_name your.domain;
    set $code_server_port 8080; # match retrieved port
    include /etc/nginx/snippets/code-server-proxy.conf;
  }
  ```
  Then run `sudo nginx -t && sudo systemctl reload nginx`.

## 🔏 Certbot Caveat

Requires `snapd` already installed. Script aborts if `snap` not found. Install snapd first if missing:

```
sudo apt update && sudo apt install -y snapd
```

## 🔥🧱 Firewall Safety

`openssh-ufw.sh`:

- Adds `OpenSSH` allow rule if absent.
- Only enables UFW after confirming the rule, mitigating lockout risk.
- Skips enable if rule confirmation fails.

## 🐘 PostgreSQL

Installs server + contrib; enables service; starts if inactive. Does not create databases or roles—post-install manual configuration is up to you.

## 🔑 Git & SSH Module

- Sets global git config (overwrites previous name/email values).
- Generates ed25519 key pair if absent.
- Public key surfaced in workflow summary for adding to hosting platforms.

## ♻️ Idempotency Examples

Re-run with:

- Added `SETUP_POSTGRES=true` (custom profile) ⇒ Only PostgreSQL script runs.
- Profile switch to include previously omitted modules ⇒ Already installed modules are detected and skipped.

## 📚 Common Scenarios

1. Full server bootstrap:
   - Profile: Full Development Server
   - Provide git_user_name/email
   - Outcome: Complete system + user environment

2. Add just nvm later:
   - Set `SETUP_NVM=true`
   - Profile: Custom
   - Outcome: nvm added; prior modules untouched

3. Infrastructure only:
   - Profile: System Services Only
   - Outcome: Services installed; no user toolchain except code-server config for target user.

4. User-only tooling on existing server:
   - Profile: User Tools Only
   - Outcome: uv, nvm, repos, Git/SSH installed; no system changes.

## 🧪 Troubleshooting Quick Reference

| Issue                                 | Check / Fix                                                                              |
| ------------------------------------- | ---------------------------------------------------------------------------------------- |
| SSH connection fails                  | Correct host, port, key format (`ssh -i key user@host`), firewall rule, reachable server |
| Missing SUDO_ACCESS_USER error        | Add secret; verify passwordless sudo                                                     |
| Certbot failure (snap not found)      | Install snapd before rerun                                                               |
| Nginx not serving code-server         | Create server block and set `$code_server_port` variable                                 |
| Code-server unreachable               | Confirm port open/local; set up reverse proxy; check `systemctl status code-server@user` |
| Git module error (missing name/email) | Provide both inputs when profile includes Git/SSH                                        |
| Port exhaustion (code-server)         | Expand port range variables                                                              |
| UFW enable skipped                    | Ensure OpenSSH rule added; rerun script                                                  |

## 📌 Manual Follow-ups After Run

- Add code-server proxy server block (and optional TLS via Certbot).
- Use retrieved SSH public key in Git hosting provider.
- Secure or rotate generated code-server password as needed.
- Create PostgreSQL roles/databases (`sudo -iu postgres psql`).

## 🛡️ Security Notes

- Limit the number of users with passwordless sudo.
- Audit `~/.ssh/authorized_keys` regularly.
- Rotate deployment key periodically.
- Review workflow run logs for unexpected warnings.

## 🧱 Extending

Add new scripts under `scripts/` following current pattern:

- Check existence first.
- Exit early on success.
- Echo status clearly.
  Then introduce a new variable in workflow logic for activation (if needed).

## 📁 Reference: Scripts

Located in `scripts/`:

- System: `openssh-ufw.sh`, `packages.sh`, `nginx.sh`, `certbot.sh`, `postgres.sh`, `code-server-*.sh`
- User: `uv.sh`, `nvm.sh`, `repos.sh`, `git-ssh.sh`

## 🙋 Getting Help

Open an issue with:

- Workflow run URL
- Relevant log excerpts
- Server OS/version
- Module(s) failing
- Steps attempted
