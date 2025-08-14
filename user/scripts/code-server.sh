#!/bin/bash
set -e

mkdir -p "/home/$USER/.config/code-server"
cat <<EOF > "/home/$USER/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:$CODE_SERVER_PORT
auth: none
cert: false
EOF

chown "$USER:$USER" "/home/$USER/.config/code-server/config.yaml"
