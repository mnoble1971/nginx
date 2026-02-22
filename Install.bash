#!/bin/bash
#
sudo dnf install -y nginx
sudo systemctl enable --now nginx

sudo dnf install -y httpd-tools
sudo mkdir -p /var/www/html /var/www/logs /var/www/dynatrace /var/www/misc /var/www/api
sudo chown -R nginx:nginx /var/www
sudo chmod -R 755 /var/www

TOKEN="$(openssl rand -hex 32)" ;echo "YOUR_TOKEN=$TOKEN"
sudo htpasswd -c /etc/nginx/.htpasswd portaluser

