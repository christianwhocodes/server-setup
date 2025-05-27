#!/bin/bash
set -e
set -u

apt update && apt upgrade -y

apt install -y \
  git curl wget ufw \
  build-essential software-properties-common \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libncursesw5-dev xz-utils tk-dev libxmlsec1-dev \
  libffi-dev liblzma-dev pandoc texlive-xetex \
  libsqlite3-dev sqlite3

ufw allow OpenSSH
ufw --force enable

echo "✓ System packages installed"
