# Install Nginx
apt install -y nginx
systemctl enable --now nginx
ufw allow 'Nginx Full'
