#!/bin/bash
set -e

sudo -u "$USER" mkdir -p "/home/$USER/.config/code-server"
cat <<EOF > "/home/$USER/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: password
password: $PASSWORD
cert: false
EOF

chown "$USER:$USER" "/home/$USER/.config/code-server/config.yaml"
