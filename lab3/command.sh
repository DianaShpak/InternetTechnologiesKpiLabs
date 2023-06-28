#Почнемо з оновлення списку пакетів операційної системи на нашому сервері
sudo apt update

#Далі встановлюємо демон vsftpd
sudo apt install vsftpd

#робим копію файлу конфігурації
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig

#Перевіряємо стан брандмауера
sudo ufw status

#Першим правилом необхідно дозволити підключення до нашого сервера протоколом SSH, 
#накше після активації брандмауера ми втратимо можливість підключатися до сервера. 
#Щоб налаштувати сервер на дозвіл вхідних SSH-з'єднань, вводимо команду:
sudo ufw allow ssh

#Після цього повернемо правила ufw до значень за промовчанням, тобто блокувати всі 
#вхідні з'єднання і дозволити всі вихідні, для цього просто вводимо дві команди послідовно, 
#одну за одною:
sudo ufw default deny incoming
sudo ufw default allow outgoing

#Ну і насамкінець, активуємо сам брандмауер ufw, для цього необхідно ввести команду:
sudo ufw enable

#Тепер брандмауер є активним. Виконайте команду sudo ufw status verbose , щоб побачити 
#активні правила брандмауера.
sudo ufw status verbose

#Система повідомляє нам, що брандмауер активний і дозволені підключення тільки SSH (порт 22).
#Оскільки у нас дозволено лише SSH підключення, то нам необхідно додати правила і для FTP підключень. 
#Відкриємо порти 20, 21 і 990, щоб була можливість підключатися через TLS:
sudo ufw allow 20,21,990/tcp

#Потім відкриємо порти 40000-50000 це діапазон пасивних портів для FTP, які потім вкажемо в конфігураційному файлі vsftpd:
sudo ufw allow 40000:50000/tcp

#Перевіримо, що в нас вийшло в результаті, для цього введемо команду:
sudo ufw status verbose

#Status: active
#Logging: on (low)
#Default: deny (incoming), allow (outgoing), disabled (routed)
#New profiles: skip

#To                         Action      From
#--                         ------      ----
#22/tcp                     ALLOW IN    Anywhere                  
#20,21,990/tcp              ALLOW IN    Anywhere                  
#40000:50000/tcp            ALLOW IN    Anywhere                  
#22/tcp (v6)                ALLOW IN    Anywhere (v6)             
#20,21,990/tcp (v6)         ALLOW IN    Anywhere (v6)             
#40000:50000/tcp (v6)       ALLOW IN    Anywhere (v6)  


sudo adduser alpha
sudo adduser beta
sudo adduser gamma
sudo adduser delta
sudo adduser omega

#password fore all user 123
#Хорошою практикою вважається обмеження користувачів FTP певним каталогом, в vsftpd 
#це реалізується за допомогою chroot jails . Коли chroot увімкнено, локальні користувачі 
#будуть за умовчанням обмежені своїм домашнім каталогом. Оскільки vsftpd захищає каталог 
#особливим чином, він не повинен бути доступним для запису користувача. Це підходить для 
#нових користувачів, які повинні підключатися тільки FTP, але існуючим користувачам, які 
#мають доступ і до SSH, може знадобитися запис і в домашню директорію.

#У цьому прикладі замість того, щоб видаляти права на запис для домашнього каталогу, 
#ми створимо каталог ftp, який буде служити chroot директорією, і каталог файлів files 
#з можливістю запису в нього для зберігання файлів.

#Створюємо директорію ftp:

sudo mkdir /home/alpha/ftp
sudo mkdir /home/beta/ftp
sudo mkdir /home/gamma/ftp
sudo mkdir /home/delta/ftp
sudo mkdir /home/omega/ftp

#Встановіть власника на цих директорій:
sudo chown nobody:nogroup /home/alpha/ftp
sudo chown nobody:nogroup /home/beta/ftp
sudo chown nobody:nogroup /home/gamma/ftp
sudo chown nobody:nogroup /home/delta/ftp
sudo chown nobody:nogroup /home/omega/ftp

#Встановимо права доступу, що забороняють запис до цієї директорії:
sudo chmod a-w /home/alpha/ftp
sudo chmod a-w /home/beta/ftp
sudo chmod a-w /home/gamma/ftp
sudo chmod a-w /home/delta/ftp
sudo chmod a-w /home/omega/ftp

#І тепер перевіримо права доступу на цей каталог:
sudo ls -la /home/alpha/ftp
sudo ls -la /home/beta/ftp
sudo ls -la /home/gamma/ftp
sudo ls -la /home/delta/ftp
sudo ls -la /home/omega/ftp

#Наступним кроком створимо директорію для завантаження файлів:
sudo mkdir /home/alpha/ftp/files
sudo mkdir /home/beta/ftp/files
sudo mkdir /home/gamma/ftp/files
sudo mkdir /home/delta/ftp/files
sudo mkdir /home/omega/ftp/files

#І дамо нашому користувачеві права власника на цю директорію:
sudo chown alpha:alpha /home/alpha/ftp/files
sudo chown beta:beta /home/beta/ftp/files
sudo chown gamma:gamma /home/gamma/ftp/files
sudo chown delta:delta /home/delta/ftp/files
sudo chown omega:omega /home/omega/ftp/files

#Після чого перевіримо нашу директорію ftp щоб переконатися що ми не припустилися 
#помилок у налаштуваннях прав доступу.

sudo ls -la /home/alpha/ftp
sudo ls -la /home/beta/ftp
sudo ls -la /home/gamma/ftp
sudo ls -la /home/delta/ftp
sudo ls -la /home/omega/ftp

#Нарешті створимо тестовий файл proverka.txt у директоріях /ftp/files, який нам знадобиться 
#пізніше, для цього введемо з терміналу команду:

echo "vsftpd freehost proverka alpha" | sudo tee /home/alpha/ftp/files/proverka.txt
echo "vsftpd freehost proverka beta"  | sudo tee /home/beta/ftp/files/proverka.txt
echo "vsftpd freehost proverka gamma" | sudo tee /home/gamma/ftp/files/proverka.txt
echo "vsftpd freehost proverka delta" | sudo tee /home/delta/ftp/files/proverka.txt
echo "vsftpd freehost proverka omega" | sudo tee /home/omega/ftp/files/proverka.txt

#Тепер, коли ми захистили ftp-каталог і дозволили користувачеві доступ лише до каталогу файлів 
#/ftp/files, можна приступати до конфігурації vsftpd.


#На цьому етапі ми дозволимо одному користувачеві з локальним обліковим записом підключатися FTP. 
#Дві ключові налаштування для цього вже задано у файлі vsftpd.conf

sudo nano /etc/vsftpd.conf

#Відкриваємо файл і переконуємося, що для директиви anonymous_enable встановлено значення NO , 
#а для директиви local_enable - YES :

#Ці параметри забороняють анонімний доступ до сервера FTP і дозволяють доступ локальним користувачам. 
#Пам'ятайте, що дозвіл локальних користувачів означає, що будь-який звичайний користувач, вказаний 
#у файлі /etc/passwd, може бути використаний для входу FTP.

#Деякі команди FTP дозволяють користувачам додавати, змінювати або видаляти файли та каталоги 
#у файловій системі сервера. Увімкніть ці команди, розкоментувавши параметр write_enable . 
#Для цього треба видалити символ ґрат (#) перед цією директивою:

#Також розкоментуйте директиву chroot_local_user , щоб запобігти доступу користувача підключеного по FTP, 
#до файлів або директорій за межами домашньої директорії:

#Потім додайте директиву user_sub_token , значенням якої є змінна оточення $USER . 
#Також додайте директиву local_root і вкажіть шлях /home/$USER/ftp , який також включає змінну 
#оточення $USER . Ці директиви роблять так, що користувачі при вході в систему будуть
#перенаправлятися до свого домашнього каталогу. Додайте ці параметри до кінця конфігураційного файлу:

user_sub_token=$USER
local_root=/home/$USER/ftp

pasv_min_port=40000
pasv_max_port=50000

userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO

#Директива userlist_deny має два сенси: якщо встановлено значення YES, користувачам зі списку буде 
#відмовлено у доступі до FTP, якщо встановлено значення NO, доступ буде дозволено лише користувачам 
#зі списку.

#Коли ви закінчите вносити зміни, збережіть файл і вийдіть із редактора. Якщо ви використовували 
#nano для редагування файлу, ви можете це зробити, натиснувши CTRL + X, Y, потім ENTER.

#На закінчення додайте свого користувача до файлу /etc/vsftpd.userlist . Використовуйте прапорець 
#-a утиліти tee для додавання до файлу:

echo "alpha" | sudo tee -a /etc/vsftpd.userlist
echo "beta" | sudo tee -a /etc/vsftpd.userlist
echo "gamma" | sudo tee -a /etc/vsftpd.userlist
echo "delta" | sudo tee -a /etc/vsftpd.userlist
echo "omega" | sudo tee -a /etc/vsftpd.userlist
echo "anonymous" | sudo tee -a /etc/vsftpd.userlist

#Перевіримо, що додавання відбулося так, як очікувалося:
cat /etc/vsftpd.userlist

#Тепер перезапe демон vsftpd, щоб застосувати зміни конфігурації:
sudo systemctl restart vsftpd

#Ми налаштували наш FTP сервер так, щоб дозволити підключення користувачів alpha, beta, gamma, delta, omega. 
#Ми відключили анонімний FTP доступ, перевіримо це, спробувавши підключитися анонімно. 
#Якщо конфігурація налаштована правильно, анонімним користувачам буде відмовлено у доступі 
#на сервер FTP. Відкрийте ще одне вікно командного рядка та виконайте команду для підключення 
#до сервера за протоколом FTP- ftp 172.20.1.80.

#Коли з'явиться запит на введення імені користувача, спробуйте увійти в систему під неіснуючим 
#користувачем, наприклад anonymous , і ви отримаєте таке повідомлення:

ftp 172.20.1.80

#Connected to 172.20.1.80.
#220 (vsFTPd 3.0.3)
#Name (172.20.1.80:chygyk): omega
#331 Please specify the password.
#Password: 
#230 Login successful.
#Remote system type is UNIX.
#Using binary mode to transfer files.
#ftp> bye
#421 Timeout.

#Закрийте з'єднання, ввівши команду bye :

#Користувачі, які відрізняються від alpha, beta, gamma, delta, omega, також не зможуть підключитися. Спробуйте підключитися 
#від імені вашого користувача, який має права sudo в системі. Йому також має бути відмовлено у 
#доступі, і це має статися до того, як Ви введете пароль:


ftp 172.20.1.80

#Connected to 172.20.1.80.
#220 (vsFTPd 3.0.3)
#Name (172.20.1.80:chygyk): 
#530 Permission denied.
#ftp: Login failed
#ftp> bye
#221 Goodbye.



#Оскільки FTP не шифрує дані передачі, включаючи облікові дані користувачів, рекомендується 
#включити TLS/SSL для забезпечення шифрування даних. Першим кроком буде створення SSL-сертифікатів 
#для використання разом із vsftpd.

#За допомогою openssl створіть новий сертифікат, використовуйте прапорець -days 365 , щоб зробити 
#його дійсним протягом одного року. Тут же зазначимо генерацію закритого 2048-бітного ключа RSA. 
#Якщо встановити прапори -keyout і -out в те саме значення, закритий ключ і сертифікат будуть 
#знаходитися в одному файлі:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem

# C=UA
# ST=Ukraine
# L=Kyiv
# O=KPI
# OU=OT
# CN=letter CA
# email=ftp.letter.net

#Вам буде запропоновано вказати інформацію для вашого сертифіката. 
#Замініть виділені значення своєю інформацією. Ці дані не дуже важливі.

#Найголовніше тут це Common Name, в нього треба ввести або IP адресу вашого сервера або його 
#ім'я (хостнейм), за яким ви будете до нього підключатися


#Після створення сертифікатів знову відкрийте конфігураційний файл vsftpd:
sudo nano /etc/vsftpd.conf

#У нижній частині файлу будуть два рядки, що починаються з rsa_ . 
#Закоментуйте їх, додавши перед кожною решітки знак #:

rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key

#Після цих рядків додайте наступні рядки, які вказують на створений вами сертифікат 
#та закритий ключ:

rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem

#Далі додайте наступні рядки, щоб заборонити анонімні з'єднання через SSL і вимагати 
#SSL для передачі даних і при вході в систему:

allow_anon_ssl=NO
# force_local_data_ssl=YES
# force_local_logins_ssl=YES

#Також настройте сервер на використання TLS протоколу, який прийшов на зміну SSL,
#додавши наступні рядки:

ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

#І насамкінець, додайте дві останні опції. Перша не вимагатиме повторного використання SSL, 
#оскільки це може зламати багато FTP-клієнтів. Друга вимагатиме "високих" шифрів, що в 
#даний час означає довжину ключа, рівну або перевищує 128 біт:

require_ssl_reuse=NO
ssl_ciphers=HIGH

#збережіть та закрийте файл. Тепер перезапустимо сервер vsftpd,
#щоб зміни набули чинності:

sudo systemctl restart vsftpd

#На цьому етапі ви більше не зможете підключитися за допомогою небезпечного FTP 
#клієнта командного рядка, як це робили раніше за прикладом цієї статті. Якщо ви 
#спробуєте підключитися, отримайте таке повідомлення про помилку:


#Тепер, коли ми дозволили цим двом користувачам отримати доступ до нашого FTP-сервера
#(і закрили його для всіх інших), останнє, що нам потрібно зробити, це налаштувати їхні 
#домашні папки.

#Для цього створіть папку /etc/vsftpd/user_config_dir/ і створюємо файли з однаковими 
#іменами користувачів:

sudo mkdir /etc/user_config_dir/
sudo touch /etc/user_config_dir/alpha
sudo touch /etc/user_config_dir/beta
sudo touch /etc/user_config_dir/gamma
sudo touch /etc/user_config_dir/delta
sudo touch /etc/user_config_dir/omega
sudo touch /etc/user_config_dir/anonymous

#Відразу після цього відредагуйте файлb таким чином:

#alpha
sudo nano /etc/user_config_dir/alpha
local_root=/home
write_enable=YES

#beta
sudo nano /etc/user_config_dir/beta
local_root=/home/beta/www
write_enable=NO

#gamma
sudo nano /etc/user_config_dir/gamma
local_root=/home/gamma/www
write_enable=YES

#delta
sudo nano /etc/user_config_dir/delta
local_root=/home
write_enable=YES

#omega
sudo nano /etc/user_config_dir/omega
local_root=/home/gamma/www
write_enable=YES

#anonymous
sudo nano /etc/user_config_dir/anonymous
local_root=/home/anonymous
write_enable=YES



sudo nano /etc/vsftpd.conf
# Setup the virtual users config folder
user_config_dir=/etc/user_config_dir/

sudo systemctl restart vsftpd

#Наведені вище параметри зрозумілі самі за себе: ми, по суті, кажемо VSFTP дозволити 
#доступ до FTP лише локальним користувачам, яких ми розмістимо у файлі user_list, отримавши
# їхню конфігурацію з папки /user_config_dir/ 

force_local_logins_ssl=NO
force_local_data_ssl=NO