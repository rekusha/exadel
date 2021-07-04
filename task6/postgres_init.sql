select 'CREATE DATABASE task6' where not exists (select from pg_database where datname = 'task6');

use task6;

create table if not exists Students(
		id serial primary key,
                Student varchar (127) not null,
                StudentId int not null);

create table if not exists Result(
		id serial primary key,
                StudentId int not null,
                Task1 varchar (127) not null,
                Task2 varchar (127) not null,
                Task3 varchar (127) not null,
                Task4 varchar (127) not null);

\copy Students(Student,StudendId) FROM './Students.csv' delitimer ',' csv header;
\copy Result(StudentId,Task1,Task2,Task3,Task4) FROM './Result.csv' delitimer ',' csv header;
