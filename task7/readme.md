# Task 7: Logging&Monitoring. Big Brother.  
 Мониторинг: Город засыпает просыпается ....  
## Tasks:  
### 1. Zabbix:  
1.1 Установить на сервер - сконфигурировать веб и базу   
1.2 Поставить на подготовленные ранее сервера или виртуалки заббикс агенты   
### EXTRA 1.2.1: сделать это ансиблом  
1.3 Сделать несколько своих дашбородов, куда вывести данные со своих триггеров (например мониторить размер базы данных из предыдущего задания и включать алерт при любом изменении ее размера - можно спровоцировать вручную)  
1.4 Active check vs passive check - применить у себя оба вида - продемонстрировать.  
1.5 Сделать безагентный чек любого ресурса (ICMP ping)  
1.6 Спровоцировать алерт - и создать Maintenance инструкцию   
1.7 Нарисовать дашборд с ключевыми узлами инфраструктуры и мониторингом как и хостов так и установленного на них софта  
  
### 2. ELK:   
Никто не забыт и ничто не забыто.  
2.1 Установить и настроить ELK   
2.2 Организовать сбор логов из докера в ELK и получать данные от запущенных контейнеров  
2.3 Настроить свои дашборды в ELK  
### EXTRA 2.4: Настроить фильтры на стороне Logstash (из поля message получить отдельные поля docker_container и docker_image)  
2.5 Настроить мониторинг в ELK - получать метрики от ваших запущенных контейнеров  
2.6 Посмотреть возможности и настройки  
  
### 3. Grafana:  
3.1 Установить Grafana интегрировать с установленным ELK  
3.2 Настроить Дашборды  
3.3 Посмотреть возможности и настройки  

-------

## Task 1  
### install ubuntu server  
#apt install openssh  
#usermod -aG sudo rekusha  
#ufw allow OpenSSH
#ufw enable


### Installing the Nginx Web Server  
sudo apt update  
sudo apt install nginx   
sudo ufw allow 'Nginx HTTP'  

### Installing MySQL  
sudo apt install mysql-server  
sudo mysql_secure_installation (при необходимости)  

### Installing PHP  
sudo apt install php-fpm php-mysql  

### Configuring Nginx to Use the PHP Processor  
sudo mkdir /var/www/<your_domain>  
sudo chown -R $USER:$USER /var/www/<your_domain>  
sudo nano /etc/nginx/sites-available/<your_domain>  
```
server {
    listen 80;
    server_name <your_domain> www.<your_domain>;
    root /var/www/<your_domain>;
    index index.html index.htm index.php;
    location / {
        try_files $uri $uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }
    location ~ /\.ht {
        deny all;
    }
}
```
sudo ln -s /etc/nginx/sites-available/<your_domain>/etc/nginx/sites-enabled/  
sudo unlink /etc/nginx/sites-enabled/default  
sudo nginx -t  
sudo systemctl reload nginx  

### Установка сервера Zabbix  
sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb  
sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb  
sudo apt update  
sudo  apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent  

### Настройка базы данных MySQL для Zabbix  
sudo mysql  
mysql> create database zabbix character set utf8 collate utf8_bin;  
mysql> create user zabbix@localhost identified by '<your_zabbix_mysql_password>';  
mysql> grant all privileges on zabbix.* to zabbix@localhost;  
mysql> quit;

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix  
sudo nano /etc/zabbix/zabbix_server.conf
```
...
### Option: DBPassword
#       Database password. Ignored for SQLite.
#       Comment this line if no password is used.
#
# Mandatory: no
# Default:
DBPassword=<zabbix_user_password_for_mysql>
...
```
### Настройка Nginx для Zabbix  

sudo nano /etc/zabbix/nginx.conf  
```
server {
        listen          80;
        server_name     <your_domain>;
```

### Настройка PHP для Zabbix  
sudo nano /etc/zabbix/php-fpm.conf  
```
php_value[date.timezone] = Europe/Kiev
```
systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm

### Конфигурация настроек для веб-интерфейса Zabbix  
идем на http://zabbix_server_name отвечаем на требуемое  
пользователь по умолчанию Admin пароль zabbix  
