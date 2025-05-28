#!/bin/bash
set -e

# Install Certbot for SSL
snap install core && snap refresh core
apt remove -y certbot || true
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot
