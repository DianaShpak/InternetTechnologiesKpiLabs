#!/bin/bash
sudo apt update
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# # Create self signed cert for HTTPS reverse proxy as Nginx
openssl genrsa -out /tmp/app.key 2048
openssl req -new -key /tmp/app.key -out /tmp/app.csr -subj "/C=UA/ST=Ukraine/L=Kyiv/O=KPI/OU=OT/CN=letter CA"
openssl x509 -req -days 365 -in /tmp/app.csr -signkey /tmp/app.key -out /tmp/app.crt
sudo chmod 644 /tmp/app.crt /tmp/app.key
echo "self signed cert done" >> /tmp/debug.log


sudo apt install -y nginx

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


# 
cat > /etc/nginx/nginx.conf <<'EOF'  
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}
http {
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';
  access_log  /var/log/nginx/access.log  main;
  sendfile            on;
  tcp_nopush          on;
  tcp_nodelay         on;
  keepalive_timeout   65;
  types_hash_max_size 2048;
  include /etc/nginx/mime.types;
  default_type        application/octet-stream;
  include /etc/nginx/conf.d/*.conf;
  server 

  {
          listen              80;
          listen       443 ssl http2 default_server;
          listen       [::]:443 ssl http2 default_server;
          server_name  _;
          root         /etc/nginx/www;
          index index.html index.htm;
          ssl_certificate "/etc/nginx/ssl/app.crt";
          ssl_certificate_key "/etc/nginx/ssl/app.key";
          ssl_session_cache shared:SSL:1m;
          ssl_session_timeout  10m;
          ssl_ciphers HIGH:!aNULL:!MD5;
          ssl_prefer_server_ciphers on;
          # Load configuration files for the default server block.
          include /etc/nginx/default.d/*.conf;

          location / {
            # it picks up default root and checks for default index.html file at the path
            }

          location /bar {
            # it picks up default root, adds /bar to the root and looks for the default index.html file at the path
           }


          error_page 404 /404.html;
              location = /40x.html {
          }

          error_page 500 502 503 504 /50x.html;
              location = /50x.html {
          }
    }
}
EOF

## Create static webpages to serve
sudo mkdir -p /etc/nginx/www
cat > /etc/nginx/www/index.html <<'EOF'  
<h1> Hello There Server APP1</h1>
  <p>
    This webpage is serverd through nginx at default root path
  </p>
EOF
sudo chmod 0755  /etc/nginx/www
sudo chmod 644 /etc/nginx/www/index.html
sudo echo "index webpage created "  >> /tmp/debug.log

sudo mkdir -p /etc/nginx/www/bar
cat > /etc/nginx/www/bar/index.html <<'EOF'  
<h1> Hello There Server APP1</h1>
  <p>
    This webpage is serverd through nginx at path /$root/bar
  </p>
EOF
sudo chmod 0755  /etc/nginx/www/bar
sudo chmod 644 /etc/nginx/www/bar/index.html
sudo echo "index webpage created for /bar"  >> /tmp/debug.log

## firewalld
sudo apt install -y firewalld
sudo systemctl unmask firewalld
sudo systemctl restart firewalld
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --reload
sudo systemctl enable firewalld
sleep 10
sudo systemctl restart firewalld
sleep 10
sudo systemctl restart nginx
sleep 10