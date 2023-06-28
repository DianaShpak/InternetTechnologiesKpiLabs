#Для коректного відображення дат необхідно подбати про синхронізацію часу. Для цього будемо використовувати демон chrony. Встановимо його:

sudo apt-get update
sudo apt-get install chrony

#Дозволимо автозапуск сервісу:

sudo systemctl enable chrony

#Установка виконується з репозиторію однією командою:

sudo apt-get install samba

#Дозволяємо автостарт сервісу:

sudo systemctl enable smbd

#І перевіримо, що сервіс запустився: 

sudo systemctl status smbd

#Розберемо найпростіший приклад надання доступу до папки – анонімний доступ для всіх користувачів без запиту пароля.

#Відкриваємо на редагування конфігураційний файл samba:

sudo nano /etc/samba/smb.conf

#І додаємо налаштування для спільної папки:

[public]
    comment = Public Folder
    path = /data/public
    public = yes
    writable = yes
    read only = no
    guest ok = yes
    create mask = 0555
    directory mask = 0555
    force create mode = 0555
    force directory mode = 0555

#[Спільна папка]  — ім'я спільної папки, яке користувачі побачать, підключившись до сервера.
#comment  - свій коментар для зручності.
#path  — шлях на сервері, де зберігатимуться дані.
#public  – для спільного доступу. Встановіть yes , якщо хочете, щоб усі могли працювати з ресурсом.
#writable  - дозволяє запис в мережеву папку.
#read only  – тільки для читання. Встановіть no , якщо користувачі повинні мати можливість створювати папки та файли.
#guest ok  - дозволяє доступ до папки гостьового облікового запису.
#create mask, directory mask, force create mode, force directory mode  — для створення нової папки або файлу призначаються зазначені права. У прикладі права будуть повні.

#Створюємо каталог на сервері та призначимо права:
sudo mkdir -p /data/public
sudo chmod 555 /data/public

#Застосовуємо налаштування samba, перезавантаживши сервіс:

sudo systemctl restart smbd
#Пробуємо підключитися до папки. Ми повинні зайти до неї без необхідності введення логіну та пароля.



sudo adduser alpha
sudo adduser beta
sudo adduser gamma

sudo passwd alpha
sudo passwd beta
sudo passwd gamma

sudo smbpasswd -a alpha
sudo smbpasswd -a beta
sudo smbpasswd -a gamma

#Створюємо каталог на сервері та призначимо права:
sudo mkdir -p /data/incoming
sudo chmod 777 /data/incoming

[incoming]
    comment = Incoming Folder
    path = /data/incoming
    public = yes
    writable = yes
    read only = no
    guest ok = yes
    invalid users = beta
    create mask = 0777
    directory mask = 0777
    force create mode = 0777
    force directory mode = 0777

sudo chmod 777 /data


[home]
    comment = Домашній
    path = /data
    public = no
    writable = no
    read only = yes
    guest ok = no
    valid users = alpha, beta, gamma
    write list = alpha, beta
    create mask = 0777
    directory mask = 0777
    force create mode = 0777
    force directory mode = 0777
    inherit owner = yes

sudo mkdir -p /data/private
sudo chmod 777 /data/private



[private]
    comment = Прихований
    path = /data/private
    public = no
    browseable=no
    guest ok = yes
    read only = yes
    writable = no
    read list = guest alpha beta
    write list = beta
    invalid users = gamma
    create mask = 0777
    directory mask = 0777
    force create mode = 0777
    force directory mode = 0777
    inherit owner = yes



sudo systemctl restart smbd
