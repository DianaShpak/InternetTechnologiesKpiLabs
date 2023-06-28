#!/bin/bash
echo "WS_2"
sudo apt update
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# # Create self signed cert for HTTPS reverse proxy as Nginx
openssl genrsa -out /tmp/app.key 2048
openssl req -new -key /tmp/app.key -out /tmp/app.csr -subj "/C=CA/ST=ON/L=Toronto/O=Digital/OU=IT/CN=app.local.com"
openssl x509 -req -days 365 -in /tmp/app.csr -signkey /tmp/app.key -out /tmp/app.crt
sudo chmod 644 /tmp/app.crt /tmp/app.key
echo "self signed cert done" >> /tmp/debug.log


sudo apt install -y nginx
sudo apt install -y apache2-utils

mkdir -p /etc/nginx/ssl
sudo cp -f /tmp/app.key /etc/nginx/ssl/app.key
sudo cp -f /tmp/app.crt /etc/nginx/ssl/app.crt
sudo chmod 755 /etc/nginx/ssl && sudo chmod -R 644 /etc/nginx/ssl/*
sudo mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo echo "nginx installed" >> /tmp/debug.log
sudo cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
sudo chmod 777 /etc/nginx/nginx.conf
sudo chmod 777 /var/log/nginx/error.log
sudo chmod 777 /var/log/nginx/access.log
sudo cat /dev/null > /etc/nginx/nginx.conf

sudo touch /etc/nginx/.htpasswd
sudo chmod 777 /etc/nginx/.htpasswd


cat > /etc/nginx/.htpasswd <<'EOF'  
alpha:$apr1$riJKaHtA$HauUETCMFlbp4PQNj.Pbk/
beta:$apr1$wWqOPZV8$seEXZdQruZudJhcr8noBu1
gamma:$apr1$Jzqa4xq4$qeWt99f/A5kH2QWXpPiNw1
EOF

# 
cat > /etc/nginx/nginx.conf <<'EOF'  
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    upstream backend1 {
        server 172.20.1.151:80;
        server 172.20.1.152:80;
    }

    upstream backend2 {
        server 172.20.1.151:443;
        server 172.20.1.152:443;
    }

    server {
        listen 8081;
        server_name _;

        location / {
            proxy_pass http://backend1;
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }

        location /bar {
            proxy_pass http://backend1/bar;
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }
    }

    server {
        listen       8444 ssl http2 default_server;
        listen       [::]:8444 ssl http2 default_server;
        server_name _;
        ssl_certificate "/etc/nginx/ssl/app.crt";
        ssl_certificate_key "/etc/nginx/ssl/app.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        location / {
            proxy_pass https://backend2;
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }

        location /bar {
            proxy_pass https://backend2/bar;
            auth_basic "Restricted Content";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }
    }
}
EOF

## firewalld
sudo apt install -y firewalld
sudo systemctl unmask firewalld
sudo systemctl restart firewalld
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --zone=public --permanent --add-port=8081/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8444/tcp
sudo firewall-cmd --reload
sudo systemctl enable firewalld
sleep 10
sudo systemctl restart firewalld
sleep 10
sudo systemctl restart nginx
sleep 10
