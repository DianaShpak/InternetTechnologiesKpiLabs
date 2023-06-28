#!/bin/bash
echo "DNS reserve"
sudo apt-get update
sudo apt-get -y install bind9 bind9utils bind9-doc
sudo dpkg-preconfigure -f noninteractive -p critical
sudo dpkg --configure -a
sudo sed -i 's/OPTIONS="-u bind"/OPTIONS="-u bind -4"/' /etc/default/bind9
sudo systemctl restart bind9

# Налаштування додаткового сервіса виконується набагато простіше
# Так як по дефолту логи в демона Bind9 пишуться в /var/log/syslog, першим кроком ми це змінимо
# для цього додаємо секцію logging в файл конфігурації /etc/bind/named.conf, це нам дасть
# можливість виділити логи з демона Bind9 в окремий файл


cat <<EOT >> /etc/bind/named.conf

logging {
    channel bind.log {
        file "/var/lib/bind/bind.log" versions 10 size 20m;
        severity notice;
        print-category yes;
        print-severity yes;
        print-time yes;
    };
  
        category queries { bind.log; };
        category default { bind.log; };
        category config { bind.log; };
};

EOT


# У верхній частині файлу /etc/bind/named.conf.options додайте ACL із приватними IP-адресами всіх ваших довірених серверів:

cat /dev/null > /etc/bind/named.conf.options
cd /etc/bind/
cat <<EOT >> named.conf.options
acl "trusted" {
        192.168.0.10;    # dns1
        192.168.0.20;    # dns2
        172.20.1.10;     # ws1
        172.20.1.20;     # ws2
        172.20.1.30;     # ws3
        172.20.1.40;     # ws4
        172.20.1.50;     # ws5
};
EOT

cat <<EOT >> named.conf.options
options {
        directory "/var/cache/bind";

        recursion yes;
        allow-recursion { trusted; };
        listen-on  port 53 { 192.168.0.20; 127.0.0.1;};   # dns1 private IP address - listen on private network only
        allow-transfer { none; };          # disable zone transfers by default

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
};

EOT

# Визначаємо slave-зони, що відповідають master-зонам основного DNS-сервера. 
# Тип використовується slave, у файлі відсутня шлях, і існує директива masters, 
# яка має бути налаштована на приватну IP-адресу основного DNS-сервера. 
# ми кілька зон для зворотного перегляду на основному DNS-сервері, їх потрібно
# також додати:

cat /dev/null > /etc/bind/named.conf.local

cat <<EOT >> named.conf.local
zone "zone01.com" {
    type slave;
    file "db.zone01.com";  # zone file path
    masters   port 53 { 192.168.0.10; };   # dns1 private IP address
};

zone "168.192.in-addr.arpa" {
    type slave;
    file "db.168.192";  # zone file path
    masters   port 53 { 192.168.0.10; };   # dns1 private IP address 
};

zone "letter.net" {
    type slave;
    file "db.letter.net";  # zone file path
    masters   port 53 { 192.168.0.10; };   # dns1 private IP address
};

zone "20.172.in-addr.arpa" {
    type slave;
    file "db.20.172";  # zone file path
    masters   port 53 { 192.168.0.10; };   # dns1 private IP address
};

EOT

#Після створення всіх файлів конфігурації, і файлів зон робимо рестарт демона і 
#перевірку конфігів які ми створили

sudo systemctl restart bind9
sudo named-checkconf -z

sudo ufw allow Bind9