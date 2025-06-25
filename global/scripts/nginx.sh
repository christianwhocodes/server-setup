# Install Nginx
apt install -y nginx apache2-utils
systemctl enable --now nginx
ufw allow 'Nginx Full'
