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
<details><summary> 1.1 Установить на сервер - сконфигурировать веб и базу   </summary>

<details><summary> some config ubuntu server  </summary>
<pre>
# apt install openssh
# usermod -aG sudo rekusha
# ufw allow OpenSSH
# ufw enable
</pre></details>

<details><summary> Installing the Nginx Web Server   </summary>
<pre>
$ sudo apt update
$ sudo apt install nginx
$ sudo ufw allow 'Nginx HTTP'
</pre></details>

<details><summary>Installing MySQL  </summary>
<pre>
$ sudo apt install mysql-server
$ sudo mysql_secure_installation (при необходимости)
</pre></details>

<details><summary>Installing PHP  </summary>
<pre>
$ sudo apt install php-fpm php-mysql
</pre></details>

<details><summary>Configuring Nginx to Use the PHP Processor  </summary>
<pre>
$ sudo mkdir /var/www/<your_domain>
$ sudo chown -R $USER:$USER /var/www/<your_domain>
$ sudo nano /etc/nginx/sites-available/<your_domain>
</pre> <pre>
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
</pre> <pre>
$ sudo ln -s /etc/nginx/sites-available/<your_domain>/etc/nginx/sites-enabled/  
$ sudo unlink /etc/nginx/sites-enabled/default  
$ sudo nginx -t  
$ sudo systemctl reload nginx  
</pre></details>

<details><summary>Установка сервера Zabbix  </summary>
<pre>
$ sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb  
$ sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb  
$ sudo apt update  
$ sudo  apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent  
</pre></details>

<details><summary>Настройка базы данных MySQL для Zabbix  </summary>
<pre>
$ sudo mysql  
mysql> create database zabbix character set utf8 collate utf8_bin;  
mysql> create user zabbix@localhost identified by 'your_zabbix_mysql_password';  
mysql> grant all privileges on zabbix.* to zabbix@localhost;  
mysql> quit;  

zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix  
sudo nano /etc/zabbix/zabbix_server.conf
</pre>
<pre>
### Option: DBPassword
#       Database password. Ignored for SQLite.
#       Comment this line if no password is used.
#
# Mandatory: no
# Default:
DBPassword=<zabbix_user_password_for_mysql>
</pre></details>

<details><summary>Настройка Nginx для Zabbix  </summary>
<pre>
sudo nano /etc/zabbix/nginx.conf  
</pre><pre>  
server {
        listen          80;
        server_name     <your_domain>;
</pre></details>

<details>
<summary>Настройка PHP для Zabbix  </summary>
<pre>
sudo nano /etc/zabbix/php-fpm.conf   
</pre><pre>
php_value[date.timezone] = Europe/Kiev  
</pre></details>

перезапускаем все что есть + добавляем сервисы в автозапуск  

<pre>
systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
</pre>
 
### на последок конфигурация настроек для веб-интерфейса Zabbix  
идем на http://zabbix_server_name отвечаем на требуемое  
пользователь по умолчанию Admin пароль zabbix  
</details>

<details><summary>1.2 Поставить на подготовленные ранее сервера или виртуалки заббикс агенты  </summary>

<details><summary>Установка агента Zabbix  </summary>
<pre>
$ sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb  
$ sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb  
$ sudo apt update  
$ sudo apt install zabbix-agent  
</pre></details>

<details><summary>Настройка агента Zabbix  </summary>
<details><summary>сгенерировать PSK и отобразить его</summary>
<pre>
$ sudo sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
$ cat /etc/zabbix/zabbix_agentd.psk
75ad6cb5e17d244ac8c00c96a1b074d0550b8e7b15d0ab3cde60cd79af280fca
</pre>
сохранить его для дальнейшего использования. потребуется для конфигурации хоста  
</details>  
<details><summary> отредактировать настройки агента Zabbix для установки безопасного подключения к серверу Zabbix  </summary>
<pre>
sudo nano /etc/zabbix/zabbix_agentd.conf
</pre><pre>
Server=zabbix_server_ip_address
ServerActive=zabbix_server_ip_address
Hostname=Second Ubuntu Server  # под каким именем агент будет виден серверу
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK 001
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
</pre><pre>
$ sudo systemctl restart zabbix-agent
$ sudo systemctl enable zabbix-agent
$ sudo ufw allow 10050/tcp
</pre>

<details><summary>добавление хоста на сервер Zabbix</summary>
http://zabbix_server_name -> login -> password  
Configuration -> Hosts -> Create host -> откроется страница настройки хоста  
указать host name и ip агента и добавить в группу/ы (подходящую)  

</details></details>
