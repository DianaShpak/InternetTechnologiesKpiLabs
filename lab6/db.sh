#!/bin/bash
echo "MYSQL"
sudo apt update

sudo apt-get update
sudo apt install -y mysql-server
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg    
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
apt-cache madison docker-ce
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker vagrant

sudo apt-get install -y docker-compose-plugin
apt-cache madison docker-compose-plugin
sudo apt-get install -y docker-compose-plugin

sudo curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version


sudo touch docker-compose.yml
sudo cat /dev/null > docker-compose.yml
cat <<EOT >> docker-compose.yml
# Use root/example as user/password credentials
version: '2.4'

services:

  db:
    image: mysql
    # NOTE: use of "mysql_native_password" is not recommended: https://dev.mysql.com/doc/refman/8.0/en/upgrading-from-previous-series.html#upgrade-caching-sha2-password
    # (this is just an example, not intended to be a production configuration)
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: testftp
    ports:
      - 33060:3306

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080

EOT

docker-compose up -d



