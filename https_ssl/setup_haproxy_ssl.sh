#!/usr/bin/env bash
# Complete HAProxy SSL Termination Setup Script

# Update and install HAProxy
sudo apt-get update
sudo apt-get install -y haproxy certbot

# Get SSL certificate (this would need to be run on the actual server)
# sudo certbot certonly --standalone -d www.isheja.tech --non-interactive --agree-tos -m l.isheja@alustudent.com

# Create HAProxy configuration
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<'EOF'
global
    daemon
    maxconn 256
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option forwardfor
    option http-server-close

frontend http_front
    bind *:80
    bind *:443 ssl crt /etc/ssl/private/www.isheja.tech.pem
    http-request redirect scheme https unless { ssl_fc }
    default_backend http_back

backend http_back
    balance roundrobin
    server web-01 18.208.149.224:80 check
    server web-02 98.93.251.113:80 check
EOF

# For testing purposes, create a placeholder certificate
sudo mkdir -p /etc/ssl/private/
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/www.isheja.tech.pem \
    -out /etc/ssl/private/www.isheja.tech.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=www.isheja.tech"

# Test configuration
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

# Restart HAProxy
sudo systemctl restart haproxy
sudo systemctl enable haproxy

echo "HAProxy SSL termination setup complete"
echo "Test with: curl -I https://www.isheja.tech"
