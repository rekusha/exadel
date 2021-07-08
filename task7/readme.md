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

<details><summary> Task 1 - Zabbix  </summary>
	
<details><summary> 1.1 Установить на сервер - сконфигурировать веб и базу DOCKER  </summary>
	
> <pre>
> curl -fsSL https://get.docker.com -o get-docker.sh
> sh get-docker.sh
> sudo usermod -aG docker $USER
> sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
> sudo chmod +x /usr/local/bin/docker-compose
> git clone https://github.com/rekusha/exadel.git
> 
> docker-compose -f exadel/task7/zabbix-letsencrypt-docker-compose.yml -p zabbix up -d
> </pre>	
> </details>
	
	
<details><summary> 1.1 Установить на сервер - сконфигурировать веб и базу   </summary>
	
> <details><summary> some config ubuntu server  </summary>
> <pre>
> # apt install openssh
> # usermod -aG sudo rekusha
> # ufw allow OpenSSH
> # ufw enable
> </pre></details>

> <details><summary> Installing the Nginx Web Server   </summary>
> <pre>
> $ sudo apt update
> $ sudo apt install nginx
> $ sudo ufw allow 'Nginx HTTP'
> </pre></details>

> <details><summary>Installing MySQL  </summary>
> <pre>
> $ sudo apt install mysql-server
> $ sudo mysql_secure_installation (при необходимости)
> </pre></details>

> <details><summary>Installing PHP  </summary>
> <pre>
> $ sudo apt install php-fpm php-mysql
> </pre></details>

> <details><summary>Configuring Nginx to Use the PHP Processor  </summary>
> <pre>
> $ sudo mkdir /var/www/<your_domain>
> $ sudo chown -R $USER:$USER /var/www/<your_domain>
> $ sudo nano /etc/nginx/sites-available/<your_domain>
> </pre> <pre>
> server {
>     listen 80;
>     server_name <your_domain> www.<your_domain>;
>     root /var/www/<your_domain>;
>     index index.html index.htm index.php;
>     location / {
>         try_files $uri $uri/ =404;
>     }
>     location ~ \.php$ {
>         include snippets/fastcgi-php.conf;
>         fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
>      }
>     location ~ /\.ht {
>         deny all;
>     }
> }
> </pre> <pre>
> $ sudo ln -s /etc/nginx/sites-available/<your_domain>/etc/nginx/sites-enabled/  
> $ sudo unlink /etc/nginx/sites-enabled/default  
> $ sudo nginx -t  
> $ sudo systemctl reload nginx  
> </pre></details>

> <details><summary>Установка сервера Zabbix  </summary>
> <pre>
> $ sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb  
> $ sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb  
> $ sudo apt update  
> $ sudo  apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent  
> </pre></details>

> <details><summary>Настройка базы данных MySQL для Zabbix  </summary>
> <pre>
> $ sudo mysql  
> mysql> create database zabbix character set utf8 collate utf8_bin;  
> mysql> create user zabbix@localhost identified by 'your_zabbix_mysql_password';  
> mysql> grant all privileges on zabbix.* to zabbix@localhost;  
> mysql> quit;  
>
> zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix  
> sudo nano /etc/zabbix/zabbix_server.conf
> </pre>
> <pre>
> ### Option: DBPassword
> #       Database password. Ignored for SQLite.
> #       Comment this line if no password is used.
> #
> # Mandatory: no
> # Default:
> DBPassword=<zabbix_user_password_for_mysql>
> </pre></details>

> <details><summary>Настройка Nginx для Zabbix  </summary>
> <pre>
> sudo nano /etc/zabbix/nginx.conf  
> </pre><pre>  
> server {
>         listen          80;
>         server_name     your_domain;
> </pre></details>
 
> <details>
> <summary>Настройка PHP для Zabbix  </summary>
> <pre>
> sudo nano /etc/zabbix/php-fpm.conf   
> </pre><pre>
> php_value[date.timezone] = Europe/Kiev  
> </pre></details>
> 
> перезапускаем все что есть + добавляем сервисы в автозапуск  
> 
> <pre>
> systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
> systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm
> </pre>
> 
> на последок конфигурация настроек для веб-интерфейса Zabbix  
> идем на http://zabbix_server_name отвечаем на требуемое  
> пользователь по умолчанию Admin пароль zabbix  </details>

<details><summary>1.2 Поставить на подготовленные ранее сервера или виртуалки заббикс агенты  </summary>

> <details><summary>Установка агента Zabbix  </summary>
> <pre>
> $ sudo wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb  
> $ sudo dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb  
> $ sudo apt update  
> $ sudo apt install zabbix-agent  
> </pre></details>

> <details><summary>Настройка агента Zabbix  </summary>
> <details><summary>сгенерировать PSK и отобразить его</summary>
> <pre>
> $ sudo sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
> $ cat /etc/zabbix/zabbix_agentd.psk
> 75ad6cb5e17d244ac8c00c96a1b074d0550b8e7b15d0ab3cde60cd79af280fca
> </pre>
> сохранить его для дальнейшего использования. потребуется для конфигурации хоста  
> </details>  
> <details><summary> отредактировать настройки агента Zabbix для установки безопасного подключения к серверу Zabbix  </summary>
> <pre>
> sudo nano /etc/zabbix/zabbix_agentd.conf
> </pre><pre>
> Server=zabbix_server_ip_address
> ServerActive=zabbix_server_ip_address
> Hostname=Second Ubuntu Server  # под каким именем агент будет виден серверу
> TLSConnect=psk
> TLSAccept=psk
> TLSPSKIdentity=PSK 001
> TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
> </pre><pre>
> $ sudo systemctl restart zabbix-agent
> $ sudo systemctl enable zabbix-agent
> $ sudo ufw allow 10050/tcp
> </pre></details>

> <details><summary>добавление хоста на сервер Zabbix</summary>
> http://zabbix_server_name -> login -> password<br>
> Configuration -> Hosts -> Create host -> откроется страница настройки хоста  <br>
> указать host name и ip агента и добавить в группу/ы (подходящую)  <br>
> interface - add -> agent ip<br>
> вкладка Templates -> выбрать группу по которой собраны метрики (если есть подходящий темплейт)<br>
> вкладка Encryption -> выбрать PSK для Connections to host и Connections from host | PSK identity PSK 001 (TLSPSKIdentity на агенте) | PSK (key from /etc/zabbix/zabbix_agentd.psk)<br>
> press ADD
> </details>
> </details>

<details><summary> 1.3 Сделать несколько своих дашбородов, куда вывести данные со своих триггеров</summary>

> <details><summary> создание объектов данных </summary>
> Для того что бы вести мониторинг надо создать обьекты для мониторинга, такой объект называется в zabbix - элемент данных(data item).
> для создания выполнить следующую последовательность действий:
> настройка - узлы сети - узел на котором создаем элемент данных - элементы данных - Создать элемент данных:
> имя - имя элемента по которому его будет просто найти и понять по названию что он делает
> ключ - выбрать - выбираем ключь по которому будет происходить мониторинг (например proc.num[mysql] - будет по казывать количество запущенных процессов mysql) 
> тип информации - в зависимости от того что должно возвращать значение ключа (у меня ключ описывает количество запущенных процессов и это целое число, значить значение integer .целое числовое.)
> интервал - интервал с каким периодом проверять значение (или в каком промежутке времени)
> ADD
> после в мониторинг - последние данные - в фильтре указываем имя или часть имени созданного объекта данных - и видим свой процесс и значение собранных данных (серые это не поддерживаемые или отключенные процессы)
> 
> по похожему алгоритму создаются прочие объекты данных 
> </details>

> <details><summary> создание тригеров </summary>
> тригер мониторит состояние объекта данных (созданного ранее) и в зависимости от заданных граничных условий определяет нормально ли выполняет свою работу объект или нет
> тригер имеет два состояния Ok и Problme
> для создания тригера проходим по пути:
> настройка - узлы сети - в строке с именем узела на котором тригер будет отслеживать объект данных выбираем пункт "триггеры" - создать триггер
> в появившемся окне заполняем:
> имя - под каким названием мы будем видеть тригер в системе
> важность - насколько критичен порог проблеммы
> выражение - описывается по сути триггер (добавляем выражение)
> элемент данных - выбрать нужный нам
> функция - по какой функции считать состояние
> результат - "меньше 1" указав такой результат говорю тригеру что они срабатывает если mysql слиентов запущенно меньше 1 процесса 
> добавив тригер увидем что он перевелся в текстовое представление last(/mysql/proc.num[mysql])<1
> 
> лицезреть тригеры удобнее по пути мониторинг - обзор(Overview) - обзор тригеров (Trigger overview) - в фильтре указать параметры по которым отобразятся тригеры (например по имени и хосту)
> </details>

> <details><summary> создание Dashboard  </summary>
> Monitoring - Dashboard - Create Dashboard
> указываем владельца панели и имя панели
> добавляем не менее 1 виджета
> указываем тип виджета (типов много выбираем кокие нам более всего подходят)
> </details>
>
> ![alt text](https://github.com/rekusha/exadel/blob/master/task7/images/task7_1.3_dash.png)
</details>

<details><summary> 1.4 Active check vs passive check - применить у себя оба вида - продемонстрировать  </summary>

> Passive check - объект крутится на сервере в заданный интервал poller открывает соединение с клиентом на порт 10050tcp, засылает запрос с нужными данными и ждет ответ <br>
> Active check - объект крутится на клиенте и в заданный интервал trapper открывает соединение с сервером на порт 10051tcp и передает ранее сформированные данные на сервер <br>
> <br>
> Пассивные проверки позволяют отправлять комманды на клиента<br>
>
> ![alt text](https://github.com/rekusha/exadel/blob/master/task7/images/task7_1.4.png)

</details>

<details><summary> 1.5 Сделать безагентный чек любого ресурса (ICMP ping)  </summary>  

> на клиентах должны быть открыты порты для ICMP  <br>
> В Zabbix для ICMP проверок используется утилита fping  <br>
> <pre>
> fping -v
> apt install fping  # если предыдущая команда не вернула версию
> </pre>
> В Zabbix по умолчанию есть шаблон Template Module ICMP Ping (может называться иначе, в зависимости от версии Zabbix). Именно его мы будем использовать для мониторинга сетевых узлов через ICMP ping. Шаблон включает в себя 3 проверки:<br>
>   ICMP ping – доступность узла по ICMP;<br>
>   ICMP loss – процент потерянных пакетов;<br>
>   ICMP response time – время ответа ICMP ping, в миллисекундах;<br>
> icmpping, icmppngloss и icmppingsec, это встроенные в zabbix ключи. Они являются Simple checks, т.е. “простой проверкой”, в которой не участвует zabbix-agent<br>
> Полный список Simple checks, для которых не нужно устанавливать агент zabbix на системы, которые нужно мониторить, можно посмотреть здесь https://www.zabbix.com/documentation/current/manual/config/items/itemtypes/simple_checks<br>
> В шаблоне находятся 3 триггера, которые следят за вышеописанными ключами и их значениями.<br>
> <br>
> Значения, при которых сработает триггер.<br>
> Для ICMP Ping Loss процент потерь за последние 5 минут равняется 20<br>
> Для Response Time за последние 5 минут значение равняется 150 миллисекундам<br>
> <br>
> Создание узла в Zabbix, подключение ICMP Ping шаблона<br>
> Configuration -> Hosts -> Create Host.<br>
> Введите Host name, выберите группу и укажите IP адрес вашего узла в Agent interfaces.<br>
> Перейдите во вкладку Templates, нажмите Select и выберете Template Module ICMP Ping.<br>
> Нажмите Add в форме выбора шаблона и затем снова Add для завершения создания узла.<br>
> В колонке Templates отображаются все шаблоны, подключенные к узлу.<br>
> Теперь проверим работу мониторинга. Перейдите в Monitoring -> Latest data, нажмите на Select возле Hosts, и выберите узел, который вы только что создали.<br>
> В столбце Last Value отображаются последние данные, которые пришли с этого узла.<br>
> Также можно посмотреть на график по определенному значению, например, ICMP Response time.<br>
> В случае возникновения проблем, вы сможете увидеть уведомления в дашборде Zabbix.<br>
</details>

<details><summary> 1.6 Спровоцировать алерт - и создать Maintenance инструкцию  </summary>

> ![alt text](https://github.com/rekusha/exadel/blob/master/task7/images/task7_1.6.png)
</details>

<details><summary> 1.7 Нарисовать дашборд с ключевыми узлами инфраструктуры и мониторингом как и хостов так и установленного на них софта  </summary>

> ![alt text](https://github.com/rekusha/exadel/blob/master/task7/images/task7_1.7.png)
</details>
</details>

<details><summary> Task 2 - ELK  </summary>

<details><summary> 1.  Установить и настроить ELK (short way + grafana)  </summary>

git clone https://github.com/rekusha/exadel.git <br>
cd exadel/task7/elkGrafana/ <br>
docker-compose up -d <br>

<pre>
Creating network "elkgrafana_elk" with driver "bridge"
Creating volume "elkgrafana_elasticsearch" with default driver
Building elasticsearch
Sending build context to Docker daemon  3.584kB
Step 1/2 : ARG ELK_VERSION
Step 2/2 : FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}
7.13.2: Pulling from elasticsearch/elasticsearch
ddf49b9115d7: Pull complete
815a15889ec1: Pull complete
ba5d33fc5cc5: Pull complete
976d4f887b1a: Pull complete
9b5ee4563932: Pull complete
ef11e8f17d0c: Pull complete
3c5ad4db1e24: Pull complete
Digest: sha256:1cecc2c7419a4f917a88c83180335bd491d623f28ac43ca7e0e69b4eca25fbd5
Status: Downloaded newer image for docker.elastic.co/elasticsearch/elasticsearch:7.13.2
 ---> 11a830014f7c
Successfully built 11a830014f7c
Successfully tagged elkgrafana_elasticsearch:latest
WARNING: Image for service elasticsearch was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Building logstash
Sending build context to Docker daemon   5.12kB
Step 1/2 : ARG ELK_VERSION
Step 2/2 : FROM docker.elastic.co/logstash/logstash:${ELK_VERSION}
7.13.2: Pulling from logstash/logstash
a4f595742a5b: Pull complete
fd1132ca70dc: Pull complete
59f2c8c5f435: Pull complete
8dcb71d88a4e: Pull complete
b0d5a23a9e4a: Pull complete
796f58e1821d: Pull complete
29c837bdbca8: Pull complete
9662c1cef6d1: Pull complete
83ce4b738228: Pull complete
4b86338e93df: Pull complete
3b74732a4830: Pull complete
Digest: sha256:ed75189449f64d3c188a0337054a1fb9dd7bfaf42f1c20442520f364fec014a7
Status: Downloaded newer image for docker.elastic.co/logstash/logstash:7.13.2
 ---> 8dc1af4dd662
Successfully built 8dc1af4dd662
Successfully tagged elkgrafana_logstash:latest
WARNING: Image for service logstash was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Building kibana
Sending build context to Docker daemon  3.584kB
Step 1/2 : ARG ELK_VERSION
Step 2/2 : FROM docker.elastic.co/kibana/kibana:${ELK_VERSION}
7.13.2: Pulling from kibana/kibana
ddf49b9115d7: Already exists
127ce1da4c72: Pull complete
0c32fd0051d1: Pull complete
3cb592252c5c: Pull complete
a497541f421d: Pull complete
5f9af552442f: Pull complete
3d82cb04e9f3: Pull complete
63f1001938f4: Pull complete
5795c0f38c9b: Pull complete
b3f3fe288119: Pull complete
ad9e03aedb1a: Pull complete
b65617011d12: Pull complete
db3a5750fdcf: Pull complete
Digest: sha256:4a50a0f198a6536b769d8b694ae94e11f2a2bc97cf6dbe61fff98c051cdedc00
Status: Downloaded newer image for docker.elastic.co/kibana/kibana:7.13.2
 ---> 6c4869a27be1
Successfully built 6c4869a27be1
Successfully tagged elkgrafana_kibana:latest
WARNING: Image for service kibana was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Pulling grafana (grafana/grafana:latest)...
latest: Pulling from grafana/grafana
540db60ca938: Pull complete
098a0cea699f: Pull complete
f8b16078991f: Pull complete
9073fea3cece: Pull complete
b56313a23917: Pull complete
4f4fb700ef54: Pull complete
2d51f6ff2020: Pull complete
2ffee8bb6f91: Pull complete
Digest: sha256:204407ba06f61315b44c2e717b2c74580d51a7d9f240f425363cc0e3e1293e77
Status: Downloaded newer image for grafana/grafana:latest
Creating elkgrafana_elasticsearch_1 ... done
Creating grafana                    ... done
Creating elkgrafana_logstash_1      ... done
Creating elkgrafana_kibana_1        ... done

$sudo docker ps

CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                           NAMES
5a374a6b7158   elkgrafana_logstash        "/usr/local/bin/dock…"   3 minutes ago   Up 3 minutes   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp, 0.0.0.0:5044->5044/tcp, :::5044->5044/tcp, 0.0.0.0:9600->9600/tcp, 0.0.0.0:5000->5000/udp, :::9600->9600/tcp, :::5000->5000/udp   						       elkgrafana_logstash_1
54e181a19bc9   elkgrafana_kibana          "/bin/tini -- /usr/l…"   3 minutes ago   Up 3 minutes   0.0.0.0:5601->5601/tcp, :::5601->5601/tcp                                                                                                                                    							    elkgrafana_kibana_1
98e4795c11d2   grafana/grafana:latest     "/run.sh"                3 minutes ago   Up 3 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp                                                                                                                                    							    grafana
323c040b7077   elkgrafana_elasticsearch   "/bin/tini -- /usr/l…"   3 minutes ago   Up 3 minutes   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 0.0.0.0:9300->9300/tcp, :::9300->9300/tcp                                                                                         						       elkgrafana_elasticsearch_1
</pre>

--------------------------
ниже другие попытки
-------------------------
> <pre>
> sudo sysctl -w vm.max_map_count=262144
> git clone https://github.com/deviantony/docker-elk.git
> cd docker-elk
> docker-compose up -d
> curl localhost:9200
> </pre>
> by default<br>
> user: elastic<br>
> password: changeme
</details>

<details><summary>2.  Организовать сбор логов из докера в ELK и получать данные от запущенных контейнеров  </summary>

> Using Logspout  
> <pre>
> sudo docker run -d --name="logspout" --volume=/var/run/docker.sock:/var/run/docker.sock gliderlabs/logspout syslog+tls://<elk_server_ip>:5000
> </pre>
</details>

<details><summary>3.  Настроить свои дашборды в ELK  </summary>

> ![alt text](https://github.com/rekusha/exadel/blob/master/task7/images/task7_2.3.png)
</details>

<details><summary> extra 4. Настроить фильтры на стороне Logstash (из поля message получить отдельные поля docker_container и docker_image)  </summary>

> если успею
</details>

<details><summary> 5. Настроить мониторинг в ELK - получать метрики от ваших запущенных контейнеров  </summary>

> 
</details>

<details><summary> куда бы деть море "лишнего" времени?! </summary>
## Установка Elasticsearch
копируем себе публичный ключ репозитория

<pre>
$ sudo su
# wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
</pre>

apt-transport-https ставим если не установлен
<pre>
# apt install apt-transport-https
</pre>

Добавляем репозиторий Elasticsearch в систему:
<pre>
# echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
</pre>

Устанавливаем Elasticsearch на Debian или Ubuntu:
<pre>
# apt update && apt install elasticsearch
</pre>

После установки добавляем elasticsearch в автозагрузку и запускаем.
<pre>
# systemctl daemon-reload 
# systemctl enable elasticsearch.service 
# systemctl start elasticsearch.service
</pre>

Проверяем, запустился ли он:
<pre>
# systemctl status elasticsearch.service
</pre>

Проверим теперь, что elasticsearch действительно нормально работает. Выполним к нему простой запрос о его статусе. 
<pre>
# curl 127.0.0.1:9200
{
  "name" : "elk",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "_8PUv6hzRtyJt-bCLc_nXQ",
  "version" : {
    "number" : "7.13.3",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "5d21bea28db1e89ecc1f66311ebdec9dc3aa7d64",
    "build_date" : "2021-07-02T12:06:10.804015202Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
</pre>

Если все в порядке, то переходим к настройке Elasticsearch.


## Настройка Elasticsearch
Настройки Elasticsearch находятся в файле /etc/elasticsearch/elasticsearch.yml. На начальном этапе нас будут интересовать следующие параметры:

<pre>
path.data: /var/lib/elasticsearch # директория для хранения данных
network.host: 127.0.0.1 # слушаем только локальный интерфейс
</pre>
По умолчанию Elasticsearch слушает localhost. Нам это и нужно, так как данные в него будет передавать logstash, который будет установлен локально. Обращаю отдельное внимание на параметр для директории с данными. Чаще всего они будут занимать значительное место, иначе зачем нам Elasticsearch :) Подумайте заранее, где вы будете хранить логи. Все остальные настройки я оставляю дефолтными.

После изменения настроек, надо перезапустить службу:
<pre>
# systemctl restart elasticsearch.service
</pre>
Смотрим, что получилось:
<pre>
# netstat -tulnp | grep 9200
tcp6       0      0 127.0.0.1:9200          :::*                    LISTEN      1479/java
</pre>
Elasticsearch повис на локальном интерфейсе. Причем я вижу, что он слушает ipv6, а про ipv4 ни слова. Но его он тоже слушает, так что все в порядке. Переходим к установке kibana.

Если вы хотите, чтобы elasticsearch слушал все сетевые интерфейсы, настройте параметр:
<pre>
network.host: 0.0.0.0
</pre>
Только не спешите сразу же запускать службу. Если запустите, получите ошибку:
<pre>
[2021-02-14T22:46:39,547][ERROR][o.e.b.Bootstrap ] [centos8] node validation exception
[1] bootstrap checks failed
[1]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
</pre>
Чтобы ее избежать, дополнительно надо добавить еще один параметр:

<pre>
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
</pre>
Эти мы указываем, что хосты кластера следует искать только локально. 

## Установка Kibana
Дальше устанавливаем web панель Kibana для визуализации данных, полученных из Elasticsearch. Тут тоже ничего сложного, репозиторий и готовые пакеты есть под все популярные платформы. Репозитории и публичный ключ для установки Kibana будут такими же, как в установке Elasticsearch. Но я еще раз все повторю для тех, кто будет устанавливать только Kibana, без всего остального. Это продукт законченный и используется не только в связке с Elasticsearch.

подключаем репозиторий и ставим из deb пакета. Добавляем публичный ключ:
<pre>
# wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
</pre>
Добавляем рпозиторий Kibana:
<pre>
# echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
</pre>
Запускаем установку Kibana:
<pre>
# apt update && apt install kibana
</pre>
Добавляем Кибана в автозагрузку и запускаем:
<pre>
# systemctl daemon-reload
# systemctl enable kibana.service
# systemctl start kibana.service
</pre>
Проверяем состояние запущенного сервиса:
<pre>
# systemctl status kibana.service
</pre>
По умолчанию, Kibana слушает порт 5601. Только не спешите его проверять после запуска. Кибана стартует долго. Подождите примерно минуту и проверяйте.
<pre>
# netstat -tulnp | grep 5601
tcp        0      0 127.0.0.1:5601          0.0.0.0:*               LISTEN      1487/node
</pre>

## Настройка Kibana

Файл с настройками Кибана располагается по пути - /etc/kibana/kibana.yml. На начальном этапе можно вообще ничего не трогать и оставить все как есть. По умолчанию kibana слушает только localhost и не позволяет подключаться удаленно. Это нормальная ситуация, если у вас будет на этом же сервере установлен nginx в качестве reverse proxy, который будет принимать подключения и проксировать их в кибана. Так и нужно делать в production, когда системой будут пользоваться разные люди из разных мест. С помощью nginx можно будет разграничивать доступ, использовать сертификат, настраивать нормальное доменное имя и т.д.

Если же у вас это тестовая установка, то можно обойтись без nginx. Для этого надо разрешить Кибана слушать внешний интерфейс и принимать подключения. Измените параметр server.host, указав ip адрес сервера, например вот так:
<pre>
server.host: "10.20.1.23"
</pre>
Если хотите, чтобы она слушала все интерфейсы, укажите в качестве адреса 0.0.0.0. После этого Kibana надо перезапустить:
<pre>
# systemctl restart kibana.service
</pre>
Теперь можно зайти в веб интерфейс по адресу http://10.20.1.23:5601.

Настройка Kibana

Можно продолжать настройку и тестирование, а когда все будет закончено, запустить nginx и настроить проксирование. Я настройку nginx оставлю на самый конец. В процессе настройки буду подключаться напрямую к Kibana.

При первом запуске Kibana предлагает настроить источники для сбора логов. Это можно сделать, нажав на Add data. К сбору данных мы перейдем чуть позже, так что можете просто изучить интерфейс и возможности этой веб панели, перейдя по ссылке Explore on my own, а затем выбрав раздел Kibana.

## Установка и настройка Logstash

Установка и настройка Logstash
Logstash устанавливается так же просто, как Elasticsearch и Kibana, из того же репозитория. Не буду еще раз показывать, как его добавить. Просто установим его и добавим в автозагрузку.

# apt install logstash
Добавляем logstash в автозагрузку:

# systemctl enable logstash.service
Запускать пока не будем, надо его сначала настроить. Основной конфиг logstash лежит по адресу /etc/logstash/logstash.yml. Я его трогать не буду, а все настройки буду по смыслу разделять по разным конфигурационным файлам в директории /etc/logstash/conf.d. Создаем первый конфиг input.conf, который будет описывать прием информации с beats агентов.

input {
  beats {
    port => 5044
  }
}
Тут все просто. Указываю, что принимаем информацию на 5044 порт. Этого достаточно. Если вы хотите использовать ssl сертификаты для передачи логов по защищенным соединениям, здесь добавляются параметры ssl. Я буду собирать данные из закрытого периметра локальной сети, у меня нет необходимости использовать ssl.

Теперь укажем, куда будем передавать данные. Тут тоже все относительно просто. Рисуем конфиг output.conf, который описывает передачу данных в Elasticsearch.

output {
        elasticsearch {
            hosts    => "localhost:9200"
            index    => "nginx-%{+YYYY.MM.dd}"
        }
	#stdout { codec => rubydebug }
}
Здесь все просто - передавать все данные в elasticsearch под указанным индексом с маской в виде даты. Разбивка индексов по дням и по типам данных удобна с точки зрения управления данными. Потом легко будет выполнять очистку данных по этим индексам. Я закомментировал последнюю строку. Она отвечает за логирование. Если ее включить, то все поступающие данные logstash будет отправлять дополнительно в системный лог. В centos это /var/log/messages. Используйте только во время отладки, иначе лог быстро разрастется дублями поступающих данных.

Остается последний конфиг с описание обработки данных. Тут начинается небольшая уличная магия, в которой я разбирался некоторое время. Расскажу ниже. Рисуем конфиг filter.conf.

filter {
 if [type] == "nginx_access" {
    grok {
        match => { "message" => "%{IPORHOST:remote_ip} - %{DATA:user} \[%{HTTPDATE:access_time}\] \"%{WORD:http_method} %{DATA:url} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:body_sent_bytes} \"%{DATA:referrer}\" \"%{DATA:agent}\"" }
    }
  }
  date {
        match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
  }
  geoip {
         source => "remote_ip"
         target => "geoip"
         add_tag => [ "nginx-geoip" ]
  }
}
Первое, что делает этот фильтр, парсит логи nginx с помощью grok, если указан соответствующий тип логов, и выделяет из лога ключевые данные, которые записывает в определенные поля, чтобы потом с ними было удобно работать. Сначала я не понял, зачем это нужно. В документации к filebeat хорошо описаны модули, идущие в комплекте, которые все это и так уже умеют делать из коробки, нужно только подключить соответствующий модуль.

Оказалось, что модули filebeat работают только в том случае, если вы отправляете данные напрямую в elasticsearch. На него вы тоже ставите соответствующий плагин и получаете отформатированные данные. Но у нас работает промежуточное звено logstash, который принимает данные. С ним, как я понял, плагины filebeat не работают, поэтому приходится отдельно в logstash парсить данные. Это не очень сложно, но тем не менее. Как я понял, это плата за удобства, которые дает logstash. Если у вас много разрозненных данных, то отправлять их напрямую в elasticsearch не так удобно, как с использованием предобработки в logstash. Если я не прав, прошу меня поправить. Я так понял этот момент.

Для фильтра grok, который использует logstash, есть удобный дебаггер, где можно посмотреть, как будут парситься ваши данные. Покажу на примере одной строки из конфига nginx. Например, возьмем такую строку из лога nginx:

180.163.220.100 - travvels.ru [05/Sep/2021:14:45:52 +0300] "GET /assets/galleries/26/1.png HTTP/1.1" 304 0 "https://travvels.ru/ru/glavnaya/" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
И посмотрим, как ее распарсит правило grok, которое я использовал в конфиге выше.

%{IPORHOST:remote_ip} - %{DATA:user} \[%{HTTPDATE:access_time}\] \"%{WORD:http_method} %{DATA:url} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:body_sent_bytes} \"%{DATA:referrer}\" \"%{DATA:agent}\"
Собственно, результат вы можете сами увидеть в дебаггере. Фильтр распарсит лог и на выходе сформирует json, где каждому значению будет присвоено свое поле, по которому потом удобно будет в еластике строить отчеты и делать выборки. Только не забывайте про формат логов. Приведенное мной правило соответствует дефолтному формату main логов в nginx. Если вы каким-то образом модифицировали формат логов, внесите изменения в grok фильтр.

Надеюсь понятно объяснил работу этого фильтра. Вы можете таким образом парсить любые логи и передавать их в еластикс. Потом на основе этих данных строить отчеты, графики, дашборды. Я планирую распарсить как мне нужно почтовые логи postfix и dovecot.

Дальше используется модуль date для того, чтобы выделять дату из поступающих логов и использовать ее в качестве даты документа в elasticsearch. Делается это для того, чтобы не возникало путаницы, если будут задержки с доставкой логов. В системе сообщения будут с одной датой, а внутри лога будет другая дата. Неудобно разбирать инциденты.

В конце я использую geoip фильтр, который на основе ip адреса, который мы получили ранее с помощью фильтра grok и записали в поле remote_ip, определяет географическое расположение. Он добавляет новые метки и записывает туда географические данные. Для его работы используется база данных из файла /usr/share/logstash/vendor/bundle/jruby/2.5.0/gems/logstash-filter-geoip-6.0.3-java/vendor/GeoLite2-City.mmdb. Она будет установлена вместе с logstash. Впоследствии вы скорее всего захотите ее обновлять. Раньше она была доступна по прямой ссылке, но с 30-го декабря 2019 года правила изменились. База по-прежнему доступна бесплатно, но для загрузки нужна регистрация на сайте сервиса. Регистрируемся и качаем отсюда - https://dev.maxmind.com/geoip/geoip2/geolite2/#Download_Access. Передаем на сервер, распаковываем и копируем в /etc/logstash файл GeoLite2-City.mmdb.

Теперь нам нужно в настройках модуля указать путь к файлу с базой. Делается это так:

geoip {
 database => "/etc/logstash/GeoLite2-City.mmdb"
 source => "remote_ip"
 target => "geoip"
 add_tag => [ "nginx-geoip" ]}
Закончили настройку logstash. Запускаем его:

# systemctl start logstash.service
Можете проверить на всякий случай лог /var/log/logstash/logstash-plain.log, чтобы убедиться в том, что все в порядке. Признаком того, что скачанная geoip база успешно добавлена будет вот эта строчка в логе:

[2021-02-14T22:39:07,111][INFO ][logstash.filters.geoip ][main] Using geoip database {:path=>"/etc/logstash/GeoLite2-City.mmdb"}
</details>




<details>
