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
   
   sudo docker run --name task6-mysql -e MYSQL_ROOT_PASSWORD=$DBPASSWORD -d --rm -p 3306:3306 -p 33060:33060 mysql:latest
   sudo docker run --name task6-postgres -e POSTGRES_PASSWORD=$DBPASSWORD -d --rm -p 5432:5432 postgres:alpine

   
   
