create database if not exists task6;

create table if not exists task6.Students (
				id int auto_increment,
                Student varchar (127) not null,
                StudentId int not null,
                primary key (id));

create table if not exists task6.Result (
				id int auto_increment,
                StudentId int,
                Task1 varchar (127) not null,
                Task2 varchar (127) not null,
                Task3 varchar (127) not null,
                Task4 varchar (127) not null,
                primary key (id));
