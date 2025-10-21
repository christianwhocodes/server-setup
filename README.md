# 🏗️ Foundry

Automated setup PowerShell scripts for Windows systems.

## 📋 Requirements

- Windows 10/11 or Windows Server
- Administrator access (for system setup)
- Internet connection
- PowerShell 5.1 or later

---

## 🌍 Global Setup _(Administrator required)_

Automated system setup PowerShell script for Windows.

### ✨ What Global Setup Does

- 🌐 Installs and configures Nginx
- 🔒 Installs and configures Certbot
- 💻 Installs Code Server
- 🐘 Installs PostgreSQL
- 🛠️ Installs essential development packages (via Chocolatey)

### 📚 Prerequisites

Ensure you have the latest Windows updates installed and PowerShell execution policy allows running scripts.

Set the execution policy (run PowerShell as Administrator):

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

It is recommended you reboot the system after major Windows updates:

```powershell
Restart-Computer
```

### 🚀 Global Quick Setup

**Step 1:** Open PowerShell as Administrator and run this command to automatically configure everything:

```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/christianwhocodes/foundry/main/system/setup.ps1" -UseBasicParsing).Content
```

**Step 2:** Restart your PowerShell session for changes to fully take effect:

```powershell
# Close and reopen PowerShell as Administrator
```

---

## 👤 User Setup _(non-administrator)_

Automated user setup PowerShell script for Windows.

### ✨ What User Setup Does

- ⚙️ Creates Code Server config file for the user
- 📗 Installs uv Python package manager (Does not install Python)
- 📗 Install nvm Node package manager for Windows (Does not install Node.js and npm themselves)
- 📁 Creates a `repos` folder in the user's home directory
- 🔧 Sets up PowerShell profile with useful aliases and functions
- ⚙️ Configures Git global user name and email
- 🔑 Generates and configures SSH key (id_ed25519)

### 📚 User Prerequisites

To create a new user on Windows, follow standard Windows user management:

1. Open Settings → Accounts → Family & other users
2. Click "Add someone else to this PC"
3. Follow the prompts to create a new user account

_(Optional)_ Give the user administrator privileges through User Accounts in Control Panel.

### 🚀 User Quick Setup

Login as the new user:

**Step 1:** Open PowerShell and run the command:

```powershell
Invoke-Expression (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/christianwhocodes/foundry/main/user/setup.ps1" -UseBasicParsing).Content
```

> ⚠️ Important: The script will output:
>
> - Your Code Server password and port number for server access
> - Your SSH public key which needs to be added to your Git hosting service (GitHub, GitLab, etc.)
>
> Save both of these for future use.

**Step 2:** Restart your PowerShell session for changes to fully take effect:

```powershell
# Close and reopen PowerShell
```

**Step 3 (Optional):** Install Node.js, Python, and global packages:

```powershell
nvm install latest
nvm use latest
npm install -g npm@latest pm2 eslint
uv python install
```

---

## 👤 Post User Setup _(Administrator required)_

After completing the user setup, an administrator must enable and start the code-server service for the new user.

### 🔐 Enable Code Server Service

On Windows, you can use Task Scheduler or NSSM (Non-Sucking Service Manager) to run code-server as a service.

**Option 1: Using Task Scheduler**

1. Open Task Scheduler
2. Create a new task that runs at user logon
3. Set the action to run: `code-server`

**Option 2: Using NSSM (Recommended)**

First, install NSSM via Chocolatey (as Administrator):

```powershell
choco install nssm -y
```

Then create the service:

```powershell
nssm install code-server-username "C:\Program Files\code-server\bin\code-server.cmd"
nssm set code-server-username AppDirectory "C:\Users\username"
nssm set code-server-username DisplayName "Code Server - username"
nssm start code-server-username
```

Replace `username` with the actual username you created.

### ✅ Verify Service Status

Check if the service is running properly:

```powershell
Get-Service code-server-username
```

You should see the service as `Running`.

### 🌐 Access Code Server

Once the service is running, you can access Code Server at:

```
http://localhost:8080
```

Use the password and port number provided during the user setup to login.

### 🔐 SSH Port Forwarding _(For Remote Access)_

For secure remote access to a Windows machine running Code Server, you can use SSH port forwarding if you have OpenSSH Server enabled on Windows.

**First, enable OpenSSH Server on Windows (as Administrator):**

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

**Then from your local computer:**

**With SSH Key:**

```bash
ssh -L 8080:localhost:8080 -i /path/to/key username@your-windows-ip
```

**Without SSH Key (password authentication):**

```bash
ssh -L 8080:localhost:8080 username@your-windows-ip
```

Then access Code Server locally at:

```
http://localhost:8080
```

This keeps your Code Server secure by not exposing it to the public internet.

---

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
