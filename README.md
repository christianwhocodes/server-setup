# 🏗️ Automate Server Setup

Automated, modular, idempotent server setup via GitHub Actions for infrastructure tooling.

## 🧭 Overview

The workflow (`.github/workflows/server-setup.yml`) connects to your server over SSH using a deployment private key, uploads the bash scripts in `scripts/`, and runs only the modules selected by a profile or by custom repository variables.

All scripts are idempotent: safe to re-run; they skip work when already satisfied.

## 🚀 Quick Start

1. Fork this repository to your own GitHub account (required to add Secrets/Variables).
2. Add repository Secrets: `SERVER_SSH_KEY`, `SUDO_ACCESS_USER`.
3. (Optional) Add Variables: `NVM_VERSION`, `CODE_SERVER_PORT_START`, `CODE_SERVER_PORT_END`, or any `SETUP_*` for the Custom profile.
4. Run the workflow: Actions → Server Setup → choose a profile and inputs.

## 🎛️ Profiles

Select one profile when dispatching the workflow:

1. **_Full Development Server_**  
   System: OpenSSH/UFW, Packages, Nginx, Certbot, Code-server, PostgreSQL  
   User: uv, nvm, repos directory, Git + SSH key

2. **_System Services Only_**  
   System modules only (includes code-server configured for target user)

3. **_User Tools Only_**  
   User modules only (uv, nvm, repos, Git + SSH key)

4. **_Custom (use repository variables)_**  
   Boolean repository variables (`SETUP_*`) decide which modules run.

## 🧩 Inputs (workflow_dispatch)

| Input          | Description                                       |
| -------------- | ------------------------------------------------- |
| server_host    | Server IP or hostname                             |
| server_port    | SSH port (default 22)                             |
| target_user    | User to configure (auto-created if missing)       |
| make_user_sudo | Gives target user passwordless sudo if true       |
| ssh_public_key | Added to target user’s authorized_keys (optional) |
| setup_profile  | One of the four profiles                          |
| git_user_name  | Required if Git/SSH module runs                   |
| git_user_email | Required if Git/SSH module runs                   |

## 🔐 Required Secrets

Note: You must use your fork to add these in Settings → Secrets and variables → Actions.

| Secret           | Purpose                                          |
| ---------------- | ------------------------------------------------ |
| SERVER_SSH_KEY   | Private key used by the workflow for SSH         |
| SUDO_ACCESS_USER | Existing passwordless sudo user for system tasks |

System modules always run as `SUDO_ACCESS_USER`. User modules run as `target_user`.

## ⚙️ Optional Variables

| Variable               | Default | Purpose                      |
| ---------------------- | ------- | ---------------------------- |
| NVM_VERSION            | v0.40.3 | nvm release tag              |
| CODE_SERVER_PORT_START | 8080    | Beginning of port scan range |
| CODE_SERVER_PORT_END   | 8100    | End of port scan range       |

Custom profile only: `SETUP_OPENSSH_UFW`, `SETUP_PACKAGES`, `SETUP_NGINX`, `SETUP_CERTBOT`, `SETUP_CODE_SERVER`, `SETUP_POSTGRES`, `SETUP_UV`, `SETUP_NVM`, `SETUP_REPOS_DIR`, `SETUP_GIT_SSH` (all boolean strings: "true"/"false").

## 🧱 Modules

System (sudo):

- 🔒 OpenSSH/UFW: Adds OpenSSH allow rule; enables UFW only after verifying rule to avoid lockout.
- 🛠️ Packages: Installs build/development libraries (git, curl, toolchains, SQLite, Pandoc, TeX, etc.).
- 🌐 Nginx: Installs and starts service; creates snippet files only (no server blocks). You must add your own site config referencing snippets.
- 🔏 Certbot: Installs via snap (requires snapd pre-existing).
- 💻 Code-server: Three scripts (install system-wide, user config selects free port + random password, enable systemd unit `code-server@target_user`).
- 🐘 PostgreSQL: Installs server, enables and starts service.

User (non-sudo):

- 🐍 uv: Installs uv and (if missing) a Python runtime via `uv python install`.
- 📗 nvm: Installs specified nvm version; attempts latest Node; updates npm.
- 📁 Repos directory: Ensures `~/repos`.
- 🔑 Git/SSH: Sets global git name/email; generates `~/.ssh/id_ed25519` key pair if absent.

## 💻 Code-server Behavior

- Port selection: If existing `config.yaml` has a port not currently bound, it is reused. If that port is busy, scans range for first free port.
- Config permissions: dir 700, file 600.
- Bind address: `127.0.0.1:<port>` (local only). To expose externally you must proxy (e.g., create an Nginx server block using the `code-server-proxy.conf` snippet and define `set $code_server_port <port>;`).
- Password generated: 24 random chars from A–Z a–z 0–9 and punctuation set used in script.

## 🌐 Nginx Snippets Installed

Files in `/etc/nginx/snippets`:

- `port-proxy.conf`: Generic pass-through expecting `$upstream_port`.
- `code-server-proxy.conf`: Pass-through + WebSocket, expects `$code_server_port`.

You must create a server block manually and set those variables.

## 🔑 Credential Retrieval

If Code-server or Git/SSH runs, workflow fetches:

- Code-server port and password from user’s `config.yaml`.
- SSH public key (`id_ed25519.pub`) for adding to hosting services.

## ♻️ Idempotency Notes

Each script:

- Checks if component already exists (binary present, directory exists, service active, key present).
- Exits early or performs minimal updates without overwriting unrelated state.

Safe to add modules later by re-running workflow with Custom profile and enabling only new modules.

## 📚 Typical Scenarios

1. New full dev box: Profile “Full Development Server”, supply git name/email.
2. Add dev tools to existing user: Profile “User Tools Only”.
3. Infrastructure only: Profile “System Services Only”.
4. Incremental addition: Custom profile + set one variable (e.g., `SETUP_POSTGRES=true`).

## 📌 Manual Follow-ups

- Nginx: Create server block referencing snippets.
- Certbot: Run `sudo certbot certonly --nginx -d your.domain` (after domain + server block).
- Code-server reverse proxy + TLS: Combine server block + certificate.

## 🛡️ Security Considerations

- Passwordless sudo restricted to `SUDO_ACCESS_USER` and optionally `target_user` if `make_user_sudo=true`.
- Deployment SSH key should be dedicated; rotate periodically.
- Generated Git SSH key remains on server (private part not exfiltrated).

## 🗂️ Repository Structure

```
.github/
  workflows/server-setup.yml
  DEPLOYMENT_GUIDE.md
  VARIABLES.md
scripts/
  *.sh
README.md
```

## 📄 License

MIT
