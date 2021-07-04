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

1. Развернуть в облаке контейнер с базой данных SQL (MySQL or PostgreSQL)  
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task3/1.1/docker_install.sh   
   chmod +x docker_install.sh  
   sudo ./docker_install.sh 
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/mysql_init.sql
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/postgres_init.sql
     
   MySql - > ``` 
   sudo docker run --name task6-mysql -e MYSQL_ROOT_PASSWORD=$DBPASSWORD -d --rm -p 3306:3306 -p 33060:33060 mysql:latest  ```
   Postgres - >  ```
   sudo docker run --name task6-postgres -e POSTGRES_PASSWORD=$DBPASSWORD -d --rm -p 5432:5432 postgres:alpine  ```
   
   ```wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - echo "deb http://apt.postgresql.org/pub/repos/apt/ 'lsb_release -cs'-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list && sudo apt install postgresql-client-13```
   
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/gDicToCsv.py  
   wget https://raw.githubusercontent.com/rekusha/exadel/master/task6/requirements.txt  
   
   sudo apt install python3-pip  
   pip install -r requirements.txt  
   chmod +x gDicToCsv.py  
   ./gDicToCsv.py  
     
   после отработки пайтон скрипта создадутся файлы students.csv и tasks.csv в них импортированные из gdocs данные и подготовленные для импорта в бд  
   
   MySql - >  
   ```
   mysql -h 127.0.0.1 -u root -p -e 'SET GLOBAL local_infile = true;'  
   mysqlimport --ignore-lines=1 --fields-terminated-by=, --columns='Student, StudentId' -h 127.0.0.1 -u root -p -L task6 ./Students.csv     
   mysqlimport --ignore-lines=1 --fields-terminated-by=, --columns='StudentId,Task1,Task2,Task3,Task4' -h 127.0.0.1 -u root -p -L task6 ./Result.csv
   mysql -h 127.0.0.1 -u root -p -e 'SET GLOBAL local_infile = false;'
   
    mysql -h 127.0.0.1 -u root -p -e "use task6; select student, task1, task2, task3, task4 from Students,Result where Students.StudentId=Result.StudentId and Student REGEXP 'Рекун';"
   ```  
     
   Postgres - >  
   ```
   sudo docker exec -it task6-postgres sh -c 'psql -h localhost -U postgres -W -f postgres_init.sql && psql -h localhost -U postgres -W -f postgers_fill.sql' 
   sudo docker exec -it task6-postgres sh -c "select students.student, task1, task2, task3, task4 from students,result where students.studentid=result.studentid and students.student ~ 'Рекун';"
   ```
   
