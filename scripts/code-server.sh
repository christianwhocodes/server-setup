#!/bin/bash
set -e
set -u

curl -fsSL https://code-server.dev/install.sh | sh

sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.config/code-server"
cat <<EOF > "/home/$USERNAME/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $PASSWORD
cert: false
EOF

chown "$USERNAME:$USERNAME" "/home/$USERNAME/.config/code-server/config.yaml"
systemctl enable --now "code-server@$USERNAME"

echo "✓ code-server installed"
