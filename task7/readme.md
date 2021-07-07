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
> 
> </details>
</details>

<details><summary> 1.4 Active check vs passive check - применить у себя оба вида - продемонстрировать  </summary>

> Passive check - объект крутится на сервере в заданный интервал poller открывает соединение с клиентом на порт 10050tcp, засылает запрос с нужными данными и ждет ответ <br>
> Active check - объект крутится на клиенте и в заданный интервал trapper открывает соединение с сервером на порт 10051tcp и передает ранее сформированные данные на сервер <br>
> <br>
> Пассивные проверки позволяют отправлять комманды на клиента<br>
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

> скоро <br>
</details>

<details><summary> 1.7 Нарисовать дашборд с ключевыми узлами инфраструктуры и мониторингом как и хостов так и установленного на них софта  </summary>

> скоро <br>
</details>
</details>

<details><summary> Task 2 - ELK  </summary>

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

# wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
Добавляем рпозиторий Kibana:

# echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
Запускаем установку Kibana:

# apt update && apt install kibana
Добавляем Кибана в автозагрузку и запускаем:

# systemctl daemon-reload
# systemctl enable kibana.service
# systemctl start kibana.service
Проверяем состояние запущенного сервиса:

# systemctl status kibana.service
По умолчанию, Kibana слушает порт 5601. Только не спешите его проверять после запуска. Кибана стартует долго. Подождите примерно минуту и проверяйте.

# netstat -tulnp | grep 5601
tcp        0      0 127.0.0.1:5601          0.0.0.0:*               LISTEN      1487/node

## Настройка Kibana


</details>
