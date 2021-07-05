\c task6;

create table if not exists tmp_Students(
		id serial primary key,
                Student varchar (127) not null,
                StudentId int not null);

create table if not exists tmp_Result(
		id serial primary key,
                StudentId int not null,
                Task1 varchar (127) not null,
                Task2 varchar (127) not null,
                Task3 varchar (127) not null,
                Task4 varchar (127) not null);

\copy tmp_Students(Student,StudentId) FROM './Students.csv' DELIMITER ',' CSV HEADER;
\copy tmp_Result(StudentId,Task1,Task2,Task3,Task4) FROM './Result.csv' DELIMITER ',' CSV HEADER;

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

insert into Students (Student, StudentId) select Student,StudentId from tmp_Students where tmp_Students.StudentId not in (select StudentId from Students);
insert into Result (StudentId,Task1,Task2,Task3,Task4) select StudentId,Task1,Task2,Task3,Task4 from tmp_Result where tmp_Result.StudentId not in (select StudentId from Result);

drop table tmp_Students;
drop table tmp_Result;
