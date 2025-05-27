#!/bin/bash
set -e

apt install -y postgresql postgresql-contrib libpq-dev
systemctl enable --now postgresql

echo "✓ PostgreSQL installed and running"
