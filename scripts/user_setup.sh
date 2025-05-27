#!/bin/bash
set -e

adduser --gecos "" --disabled-login "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo "$USERNAME"
usermod -aG www-data "$USERNAME"

mkdir -p "/home/$USERNAME/github/$USERNAME"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
chmod -R 700 "/home/$USERNAME/github"

echo "✓ User $USERNAME created"
