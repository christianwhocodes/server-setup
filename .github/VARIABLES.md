# 🧰 Repository Variables & Secrets Reference

🍴 Before you begin: fork this repository to your GitHub account so you can add Secrets and Variables in your own copy.

This document defines configuration surfaces consumed by `setup-server.yml`.

## 🔐 Secrets (Required)

### SERVER_SSH_KEY

Private SSH key used by the workflow runner to connect to the server. The corresponding public key must be present in `~/.ssh/authorized_keys` for `SUDO_ACCESS_USER` (and any other target you connect as).

### SUDO_ACCESS_USER

Existing user on the server with passwordless sudo (`NOPASSWD:ALL`). Used whenever system modules are executed (package installs, service management). Must be reachable via `SERVER_SSH_KEY`.

## ⚙️ Optional Variables (General)

| Variable               | Default | Description                              |
| ---------------------- | ------- | ---------------------------------------- |
| NVM_VERSION            | v0.40.3 | nvm tag used by install script           |
| CODE_SERVER_PORT_START | 8080    | Inclusive lower bound for free port scan |
| CODE_SERVER_PORT_END   | 8100    | Inclusive upper bound for free port scan |

## 🎛️ Custom Profile Module Variables

Only evaluated when `setup_profile == "Custom (use repository variables)"`. Each must be set to literal string `"true"` or `"false"` (GitHub stores them as strings).

System (run via `SUDO_ACCESS_USER`):

- SETUP_OPENSSH_UFW
- SETUP_PACKAGES
- SETUP_NGINX
- SETUP_CERTBOT
- SETUP_CODE_SERVER (triggers all 3 code-server steps)
- SETUP_POSTGRES

User (run as `target_user`):

- SETUP_UV
- SETUP_NVM
- SETUP_REPOS_DIR
- SETUP_GIT_SSH

## 📜 Module Summaries

| Variable          | Script(s)                                  | Notes                                                       |
| ----------------- | ------------------------------------------ | ----------------------------------------------------------- |
| SETUP_OPENSSH_UFW | foundry-openssh-ufw.sh                     | Adds OpenSSH allow rule; enables UFW only if rule confirmed |
| SETUP_PACKAGES    | foundry-packages.sh                        | Development toolchain & libs                                |
| SETUP_NGINX       | foundry-nginx.sh                           | Installs, enables service; creates proxy snippets only      |
| SETUP_CERTBOT     | foundry-certbot.sh                         | Requires pre-installed snapd                                |
| SETUP_CODE_SERVER | install, config, service scripts (3 files) | Port/password generation in user config step                |
| SETUP_POSTGRES    | foundry-postgres.sh                        | Enables & starts service                                    |
| SETUP_UV          | foundry-uv.sh                              | Installs uv + Python if missing                             |
| SETUP_NVM         | foundry-nvm.sh                             | Installs Node + updates npm                                 |
| SETUP_REPOS_DIR   | foundry-repos.sh                           | Ensures ~/repos                                             |
| SETUP_GIT_SSH     | foundry-git-ssh.sh                         | Needs workflow inputs git_user_name/email                   |

## 💻🔑 Code-server Port + Password Logic

- Existing config used if its port is currently free.
- If port busy, scans `[CODE_SERVER_PORT_START, CODE_SERVER_PORT_END]` for first free.
- Password: 24 random characters (A–Z a–z 0–9 and selected punctuation).
- Bind: `127.0.0.1:<port>` (must proxy externally).

## 🌐 Nginx Snippets

Scripts create:

- `/etc/nginx/snippets/port-proxy.conf` (expects `$upstream_port`)
- `/etc/nginx/snippets/code-server-proxy.conf` (expects `$code_server_port`)

You must provide a server block that sets those variables and includes the snippet.

## ♻️ Idempotency

Variables only control whether a script runs. Each script internally checks:

- Binary presence
- Service state
- Directory/key existence
  Re-running with `"true"` does not break prior setup.

## 📝 When Git Inputs Are Required

`git_user_name` and `git_user_email` must be provided if:

- Profile includes Git/SSH module (Full Development Server, User Tools Only)
- Custom profile sets `SETUP_GIT_SSH=true`

## 🧪 Example Custom Configuration

Enable only Nginx + Code-server + nvm:

```
SETUP_NGINX=true
SETUP_CODE_SERVER=true
SETUP_NVM=true
```

Dispatch workflow with profile: `Custom (use repository variables)`.

## 🛡️ Security Notes

- Limit `SUDO_ACCESS_USER` privileges to what is necessary.
- Rotate `SERVER_SSH_KEY` regularly.
- Generated user SSH key (`id_ed25519`) remains on server; only public key is exported to workflow summary.
