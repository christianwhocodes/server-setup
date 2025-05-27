#!/bin/bash
set -e
set -u

apt install -y nginx
systemctl enable --now nginx
ufw allow 'Nginx Full'

echo "✓ Nginx installed and running"
