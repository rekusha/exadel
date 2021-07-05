# Task 6: Databases. Remember everything.  
# Базы данных. Кто владеет информацией, тот владеет миром  
  
## Важные моменты:  
Основные понятия баз данных. Познакомиться с существующими базами данных. Различия SQL/NoSQL баз данных (Примеры)  
  
## Tasks:  
1. Развернуть в облаке контейнер с базой данных SQL (MySQL or PostgreSQL)  
2. Заполнить базу данных. Сделать две таблицы:  
    Students (ID; Student; StudentId);  
    Result (ID; StudentId; Task1; Task2; Task3; Task4);  
    Данные брать из:  
    https://docs.google.com/spreadsheets/d/1bJ6aDyDSBPAbck56ji6q98rw8S69i_cDymm4gN0vu3o/edit?ts=60c0e27d#gid=0  
      ## EXTRA: 2.1. Написать SQL скрипт, который будет заполнять базу данных и проверять на наличие уже существующих таблиц/записей.  
3. Написать запрос который по вашей фамилии будет находить информацию по выполненным заданиям и выводить результат на экран.  
4. Сделайте dump базы данных, удалите существующую и восстановите из дампа.  
5. Написать Ansible роль для развертывания SQL или noSQL базы данных. Креды не должны храниться в GitHub.  
## EXTRA:   
1. Прочитать про репликацию SQL и NoSQL.  
2. Написать Ansible роль для создания SQL/NoSQL кластера.  
3. Написать Pipeline для Jenkins который будет запускать ансибл плейбуки для SQL/NoSQL.  

------------------

## 1. Развернуть в облаке контейнер с базой данных SQL (MySQL or PostgreSQL)
   
   установка докера и старт контейнера с бд (без проброса папок для хранения бд ибо пока нет необходимости)
   ```
   DBPASSWORD=<password>
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task3/1.1/docker_install.sh   
   chmod +x docker_install.sh  
   sudo ./docker_install.sh 
   ```
   
   MySql - > 
   ``` 
   $sudo docker run --name task6-mysql -e MYSQL_ROOT_PASSWORD=$DBPASSWORD -d --rm -p 3306:3306 -p 33060:33060 mysql:latest  
   
   $sudo apt install mysql-client-core-8.0
   ```
   
   Postgres - >  
   ```
   sudo docker run --name task6-postgres -e POSTGRES_PASSWORD=$DBPASSWORD -d --rm -p 5432:5432 postgres:alpine  
   
   sudo apt -y install vim bash-completion wget
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - 
   echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
   sudo apt update
   sudo apt install postgresql-client-13
   ```

## 2. создание бд, наполнение табличных данных из .csv файлов с последующим выводом информации про объект по фамилии:  
   ```
   
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/gDicToCsv.py  
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/requirements.txt  
   
   sudo apt install python3-pip && pip install -r requirements.txt && python3 gDicToCsv.py  
   # после отработки пайтон скрипта будут созданы файлы Students.csv и Tasks.csv в них импортированные из gdocs данные и подготовленные для импорта в бд  
   ```
   
   MySql - >  
   ```
   $ mysqlshow -h 127.0.0.1 -u root -p -t
   Enter password:
   +--------------------+
   |     Databases      |
   +--------------------+
   | information_schema |
   | mysql              |
   | performance_schema |
   | sys                |
   +--------------------+
   # exit
   
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/mysql_init.sql  
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e 'source ./mysql_init.sql'
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e 'SET GLOBAL local_infile = true;'

   mysqlimport --ignore-lines=1 --fields-terminated-by=, --columns='Student, StudentId' -h 127.0.0.1 -u root --password=$DBPASSWORD -L task6 ./Students.csv     
   mysqlimport --ignore-lines=1 --fields-terminated-by=, --columns='StudentId,Task1,Task2,Task3,Task4' -h 127.0.0.1 -u root --password=$DBPASSWORD -L task6 ./Result.csv
   
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e 'SET GLOBAL local_infile = false;'
   ```  
     
   Postgres - >  
   ```
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/postgres_init.sql  
   psql -h localhost -U postgres -W -c 'CREATE DATABASE task6'

   psql -h localhost -U postgres -W -f postgres_init.sql  
   psql -h localhost -U postgres -W task6 -c "\copy Students(Student,StudentId) FROM './Students.csv' DELIMITER ',' CSV HEADER;"  
   psql -h localhost -U postgres -W task6 -c "\copy Result(StudentId,Task1,Task2,Task3,Task4) FROM './Result.csv' DELIMITER ',' CSV HEADER;"
   ```
   # EXTRA 2.1  
   собрать временную таблицу общую или пару временных таблиц  
   сделать перенос данных из временной таблицы в целевую с проверкой есть ли строка под "курсором" в целевой таблице и если нет выполнить перенос строки  
   после завершения обработки дропнуть временные таблицу/ы.  
   в коде см -> EXTRA2_1.sql (это файл для postgres, для mysql надо заменить синтаксис команды импорта из .csv файла)
   
   
## 3. Написать запрос который по вашей фамилии будет находить информацию по выполненным заданиям и выводить результат на экран.
   MySql - >  
   ```
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e "use task6; select student, task1, task2, task3, task4 from Students,Result where Students.StudentId=Result.StudentId and Student REGEXP 'Рекун';"
    
    +-------------------------------+-------+-------+-------+-------+
    | student                       | task1 | task2 | task3 | task4 |
    +-------------------------------+-------+-------+-------+-------+
    |Александр Рекун               | Done  | Done  | Done  | Done
    +-------------------------------+-------+-------+-------+-------+

   ```  
     
   Postgres - >  
   ```
   psql -h localhost -U postgres -W task6 -c "select students.student, task1, task2, task3, task4 from students,result where students.studentid=result.studentid and students.student ~ 'Рекун'";
   
        student     | task1 | task2 | task3 | task4
   -----------------+-------+-------+-------+-------
   Александр Рекун | Done  | Done  | Done  | Done
   (1 row)
   ```
## 4. создание дампа бд в файл, удаление бд, восстановление данных из дампа:  
   MySql - >  
   ```
   mysqldump -h 127.0.0.1 -u root --password=$DBPASSWORD task6 > task6_mysql_dump.sql    
   
   mysqladmin -h 127.0.0.1 -u root --password=$DBPASSWORD drop task6

   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e 'CREATE DATABASE task6'
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD task6 < task6_mysql_dump.sql
   
   mysql -h 127.0.0.1 -u root --password=$DBPASSWORD -e "use task6; select student, task1, task2, task3, task4 from Students,Result where Students.StudentId=Result.StudentId and Student REGEXP 'Рекун';"
    
    +-------------------------------+-------+-------+-------+-------+
    | student                       | task1 | task2 | task3 | task4 |
    +-------------------------------+-------+-------+-------+-------+
    |Александр Рекун               | Done  | Done  | Done  | Done
    +-------------------------------+-------+-------+-------+-------+
   ```
   Postgres - >  
   ```
   pg_dump -h 127.0.0.1 -U postgres -W task6 > task6_postgres_dump.sql 
   
   psql -h localhost -U postgres -W -c "DROP DATABASE task6;"
   psql -h localhost -U postgres -W -c 'CREATE DATABASE task6'
   
   psql -h 127.0.0.1 -U postgres -W task6 < task6_postgres_dump.sql  
   
   $ psql -h localhost -U postgres -W task6 -c "select students.student, task1, task2, task3, task4 from students,result where students.studentid=result.studentid and students.student ~ 'Рекун'";
   
        student     | task1 | task2 | task3 | task4
   -----------------+-------+-------+-------+-------
    Александр Рекун | Done  | Done  | Done  | Done
   (1 row)
   ```
## 5. Написать Ansible роль для развертывания SQL или noSQL базы данных. Креды не должны храниться в GitHub.  
/ansible_pb/postgres.yml
/ansible_pb/mysql.yml

------------------------------
 ## EXTRA 2.
 Написать Ansible роль для создания SQL/NoSQL кластера.
 для начала сделаем без ансибла чтоб потом "перепаковать"
 
 создадим рабочий каталоги переходим в него
 ```
 mkdir -p /opt/docker/postgresql && cd /opt/docker/postgresql
 ```
 убелимся в существовании перебенной с паролем и если ее нет то создадим
 ```
 echo $DBPASSWORD
 DBPASSWORD=password  # если переменной нет то создадим
 ```
 опишем наши контейнеры
 nano docker-compose.yml
 ```
---
services:

  postgresql_01:
    image: postgres
    container_name: postgresql_01
    restart: always
    volumes:
      - /data/postgresql_01:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: $DBPASSWORD

  postgresql_02:
    image: postgres
    container_name: postgresql_02
    restart: always
    volumes:
      - /data/postgresql_02/:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: $DBPASSWORD
 ```
 postgresql_01/postgresql_02 — названия сервисов контейнеры которых будем поднимать
 image - используемый образ
 container_name - имя контейнера присваиваемое ему при запуске
 restart - в каких случаях контейнер будет стартовать
 volumes - проброс каталога хоста внутрь контейнера
 environment - для инициализации бд надо чтоб был присвоем пароль поэтому задаем POSTGRES_PASSWORD
 
 запускаем
 ```
 sudo docker-compose up -d
 
 Creating postgresql_02 ... done
 Creating postgresql_01 ... done
 ```
 
 по выполнению $sudo docker ps должны увидеть наши два контейнера в списке 
 postgresql_01 - мастер
 postgresql_02 - не мастер )
 
 ### настройка для мастера
 ```
 docker exec -it postgresql_01 bash
 su - postgres
 createuser --replication -P repluser
 # вводим пароль для нового пользователя
 exit
 exit
 ```
 nano /data/postgresql_01/postgresql.conf
 ```
 wal_level = replica
 max_wal_senders = 2
 max_replication_slots = 2
 hot_standby = on
 hot_standby_feedback = on
 ```
 wal_level указывает, сколько информации записывается в WAL (журнал операций, который используется для репликации). Значение replica указывает на необходимость записывать только данные для поддержки архивирования WAL и репликации.
 max_wal_senders — количество планируемых слейвов; 
 max_replication_slots — максимальное число слотов репликации (данный параметр не нужен для postgresql 9.2 — с ним сервер не запустится); 
 hot_standby — определяет, можно или нет подключаться к postgresql для выполнения запросов в процессе восстановления; 
 hot_standby_feedback — определяет, будет или нет сервер slave сообщать мастеру о запросах, которые он выполняет.
 
 Посмотрим подсеть, которая используется для контейнеров с postgresql:
 ```
 sudo docker network inspect postgresql_default | grep Subnet
 "Subnet": "172.19.0.0/16",
 ```
 
 nano /data/postgresql_01/pg_hba.conf 
 добавляем строку после остальных «host replication»
 ```
 host    replication     all             172.19.0.0/16           md5
 ```
 этим разрешили подключение пользователю replication из подсети 172.19.0.0/16 с проверкой подлинности по паролю
 
 для применений всех изменений на мастере перезапускаем контейнер
 ```
 sudo docker restart postgresql_01
 ```
 
 ### настройка для НЕ мастера
 удалить все старое содержимое базы не мастера
 зайти в баш не мастера
 выполнить подключение к мастеру с указанием пользователя и метода для репликации
 ```
 rm -r /data/postgresql_02/*
 sudo docker exec -it postgresql_02 bash
 su - postgres -c "pg_basebackup --host=postgresql_01 --username=repluser --pgdata=/var/lib/postgresql/data --wal-method=stream --write-recovery-conf"
 после успешного ввода пароля для repluser от мастер хоста начнется процесс репликации
 ```
 
 для проверки успешности работы настроенной процедуры выполнить для мастера и не мастера
 ```
 sudo docker exec -it postgresql_01 su - postgres -c "psql -c 'select * from pg_stat_replication;'"
 sudo docker exec -it postgresql_02 su - postgres -c "psql -c 'select * from pg_stat_wal_receiver;'"
 ```
