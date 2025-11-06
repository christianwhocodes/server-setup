#!/bin/bash
set -e

if ! command -v ufw >/dev/null 2>&1; then
  apt-get install -y ufw || true
fi

if command -v ufw >/dev/null 2>&1; then
  if ufw status | grep -q "Status: inactive"; then
    ufw allow OpenSSH || true
    ufw --force enable || true
  fi
fi
