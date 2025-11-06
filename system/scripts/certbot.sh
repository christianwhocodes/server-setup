#!/bin/bash
set -e

snap install core && snap refresh core

apt remove -y certbot || true

snap install --classic certbot

ln -sf /snap/bin/certbot /usr/bin/certbot
