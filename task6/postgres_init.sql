CREATE DATABASE task6;

\c task6;

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
