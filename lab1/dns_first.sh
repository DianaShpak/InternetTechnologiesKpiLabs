#!/bin/bash
echo "DNS first"
sudo apt-get update
sudo apt-get -y install bind9 bind9utils bind9-doc
sudo dpkg-preconfigure -f noninteractive -p critical
sudo dpkg --configure -a
sudo sed -i 's/OPTIONS="-u bind"/OPTIONS="-u bind -4"/' /etc/default/bind9
sudo systemctl restart bind9

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

#Очищаємо файл конфігурації
cat /dev/null > /etc/bind/named.conf.options
cd /etc/bind/

#Далі над існуючим блоком options створюємо новий блок ACL (список контролю доступу) 
#під назвою trusted. Саме тут ми створимо список клієнтів, для яких ми дозволятимемо 
#рекурсивні DNS-запити (тобто запити від ваших серверів, що знаходяться в тому самому 
#центрі обробки даних, що й ns1). За допомогою нашого прикладу приватних IP-адрес 
#ми додамо dns1, dns2, ws1, ws2, ws3, ws4 і ws5 до нашого списку надійних клієнтів:

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

#Далі налаштовуємо блок options

cat <<EOT >> named.conf.options
options {
        directory "/var/cache/bind";

        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients
        listen-on port 53 { 192.168.0.10;};   # dns1 private IP address - listen on private network only
        allow-transfer { none; };      # disable zone transfers by default

        forwarders {
                8.8.8.8;
                8.8.4.4;
        };
};
EOT

#Далі виконуємо налаштування локального конфіга, в якому задаємо зони для
#прямого і зворотнього перегляду, оскільки у нас за варіантом дві зони
# і айпі адреси які ми обрали для наших днс серверів і задаються в різних 
# просторах IP-адрес то відповідно у нас буде 4 зони 2 для прямого перегляду
# і 2 для зворотнього


cat /dev/null > /etc/bind/named.conf.local

cat <<EOT >> named.conf.local
zone "zone01.com" {
    type master;
    file "/etc/bind/db.zone01.com";  # zone file path
    allow-transfer { 192.168.0.20; };   # dns2 private IP address - secondary
    also-notify { 192.168.0.20; };   # dns2 private IP address - secondary
};

zone "168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.168.192";  # zone file path
    allow-transfer { 192.168.0.20; };   # dns2 private IP address - secondary
    also-notify { 192.168.0.20; };   # dns2 private IP address - secondary
};

zone "letter.net" {
    type master;
    file "/etc/bind/db.letter.net";  # zone file path
    allow-transfer { 192.168.0.20; };   # dns2 private IP address - secondary
    also-notify { 192.168.0.20; };   # dns2 private IP address - secondary
};

zone "20.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.20.172";  # zone file path
    allow-transfer { 192.168.0.20; };   # dns2 private IP address - secondary
    also-notify { 192.168.0.20; };   # dns2 private IP address - secondary
};

EOT

# Далі створюємо вже самі файли конфігурації самих зон для прямого перегляду, це місце де ми будемо
# оприділяти ДНС записи, CNAME, SOA
# Файли зони для зворотного перегляду є місцем, де ми будемо визначати PTR 
# записів DNS для перегляду DNS, коли DNS отримує запит для IP-адреси, наприклад, 
# “192.168.0.10”, вона буде шукати файл (файли) зони для зворотного перегляду, щоб отримати 
# відповідне повне доменне ім'я dns1.zone01.com
# наші ресурси ми розділили по 2 зонах в зоні zone01.com маємо наступний список серверів
# dns1, dns2, alpha, beta  а в зоні letter.net - gamma, delta, omega 
# 

sudo cp /etc/bind/db.local /etc/bind/db.zone01.com
cd /etc/bind/
cat /dev/null > /etc/bind/db.zone01.com
cat <<EOT >> db.zone01.com
\$TTL    604800
@       IN      SOA     dns1.zone01.com. admin.zone01.com. (
                  3     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
             
dns1            IN      A      192.168.0.10
dns2            IN      A      192.168.0.20
alpha           IN      A      172.20.1.10
beta            IN      A      172.20.1.20
ws1             IN      CNAME  alpha
ws2             IN      CNAME  beta

; name servers
@   IN      NS      dns1
    IN      NS      dns2
    IN      NS      alpha
    IN      NS      beta

EOT

sudo cp /etc/bind/db.local /etc/bind/db.168.192
cd /etc/bind/
cat /dev/null > /etc/bind/db.168.192
cat <<EOT >> db.168.192
\$TTL    604800
@       IN      SOA     zone01.com. admin.zone01.com. (
                  3     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL

; name servers
      IN      NS      dns1.zone01.com.
      IN      NS      dns2.zone01.com.

; PTR Records
10.0.168.192.in-addr.arpa. 33692 IN PTR dns1.zone01.com. ;192.168.0.10
20.0.168.192.in-addr.arpa. 33692 IN PTR dns2.zone01.com. ;192.168.0.20

EOT

sudo cp /etc/bind/db.127 /etc/bind/db.letter.net
cd /etc/bind/
cat /dev/null > /etc/bind/db.letter.net
cat <<EOT >> db.letter.net
\$TTL    604800
@       IN      SOA     dns1.letter.net. admin.letter.net. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

gamma           IN      A      172.20.1.30
delta           IN      A      172.20.1.40
omega           IN      A      172.20.1.50
ws3             IN      CNAME  gamma
ws4             IN      CNAME  delta
ws5             IN      CNAME  omega

;name servers
@   IN      NS      gamma
    IN      NS      delta
    IN      NS      omega

EOT


sudo cp /etc/bind/db.local /etc/bind/db.20.172
cd /etc/bind/
cat /dev/null > /etc/bind/db.20.172
cat <<EOT >> db.20.172
\$TTL    604800
@       IN      SOA     zone01.com. admin.zone01.com. (
                  3     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL

; name servers
      IN      NS      alpha.zone01.com.
      IN      NS      beta.zone01.com.
      IN      NS      gamma.letter.com.
      IN      NS      delta.letter.com.
      IN      NS      omega.letter.com.

; PTR Records

10.1.20.172.in-addr.arpa.   IN PTR alpha.zone01.com.   ;172.20.1.10
20.1.20.172.in-addr.arpa.   IN PTR beta.zone01.com.    ;172.20.1.20
30.1.20.172.in-addr.arpa.   IN PTR gamma.letter.com.   ;172.20.1.30
40.1.20.172.in-addr.arpa.   IN PTR delta.letter.com.   ;172.20.1.40
50.1.20.172.in-addr.arpa.   IN PTR omega.letter.com.   ;172.20.1.50

EOT

#Після створення всіх файлів конфігурації, і файлів зон робимо рестарт демона і 
#і перевірку конфігів які ми створили

sudo systemctl restart bind9
sudo named-checkconf -z
sudo named-checkzone zone01.com /etc/bind/db.zone01.com
sudo named-checkzone letter.net /etc/bind/db.letter.net
sudo systemctl restart bind9
sudo ufw allow Bind9
