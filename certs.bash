sudo mkdir -p /etc/nginx/certs

cat <<'EOF' | sudo tee /etc/nginx/certs/openssl-ip.cnf >/dev/null
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
req_extensions     = req_ext
distinguished_name = dn

[dn]
CN = 192.168.18.57

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = 192.168.18.57
EOF

sudo openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
  -keyout /etc/nginx/certs/nginx.key \
  -out /etc/nginx/certs/nginx.crt \
  -config /etc/nginx/certs/openssl-ip.cnf \
  -extensions req_ext

sudo chmod 600 /etc/nginx/certs/nginx.key