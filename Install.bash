#!/bin/bash
#
IP=`hostname -I | awk '{print $1}'`
sudo dnf install -y nginx
sudo systemctl enable --now nginx

sudo dnf install -y httpd-tools
sudo mkdir -p /var/www/html /var/www/logs /var/www/dynatrace /var/www/misc /var/www/api
sudo chown -R nginx:nginx /var/www
sudo chmod -R 755 /var/www

echo "log test" | sudo tee /var/www/logs/test.log >/dev/null
echo "dynatrace test" | sudo tee /var/www/dynatrace/report.txt >/dev/null
echo "misc test" | sudo tee /var/www/misc/readme.txt >/dev/null
echo '{"status":"ok"}' | sudo tee /var/www/api/health.json >/dev/null

TOKEN="$(openssl rand -hex 32)" ;echo "YOUR_TOKEN=$TOKEN"
sudo htpasswd -c /etc/nginx/.htpasswd portaluser

cp index.html /var/www/html/index.html
cp portal.conf /etc/nginx/conf.d/portal.conf
sed -i "s/insert_token/${TOKEN}/g" /etc/nginx/conf.d/portal.conf
cp nginx.conf /etc/nginx/nginx.conf

# certs
sudo mkdir -p /etc/nginx/certs
cp openssl-ip.cnf /etc/nginx/certs/openssl-ip.cnf
sed -i "s/insert_ip/${IP}/g" /etc/nginx/certs/openssl-ip.cnf
sudo openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/nginx.key \
  -out /etc/nginx/certs/nginx.crt \
  -config /etc/nginx/certs/openssl-ip.cnf \
  -extensions req_ext

sudo chmod 600 /etc/nginx/certs/nginx.key

sudo nginx -t && sudo systemctl reload nginx

setenforce 0
echo "YOUR_TOKEN=$TOKEN"

echo "curl -ik -H \"Authorization: Bearer $TOKEN\" https://$IP/api/dynatrace/report.txt"