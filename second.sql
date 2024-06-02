use [master]
go

if db_id('Academy') is not null
begin
	drop database [Academy]
end
go

create database [Academy]
go

use [Academy]
go

create table [Assistants]
(
	[Id] int not null identity(1, 1) primary key,
	[TeacherId] int not null
)
go

create table [Curators]
(
	[Id] int not null identity(1, 1) primary key,
	[TeacherId] int not null
)
go

create table [Deans]
(
	[Id] int not null identity(1, 1) primary key,
	[TeacherId] int not null
)
go

create table [Departments]
(
	[Id] int not null identity(1, 1) primary key,
	[Building] int not null check ([Building] between 1 and 5),
	[Name] nvarchar(100) not null unique check ([Name] <> N''),
	[FacultyId] int not null,
	[HeadId] int not null
)
go

create table [Faculties]
(
	[Id] int not null identity(1, 1) primary key,
	[Building] int not null check ([Building] between 1 and 5),
	[Name] nvarchar(100) not null unique check ([Name] <> N''),
	[DeanId] int not null
)
go

create table [Groups]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(10) not null unique check ([Name] <> N''),
	[Year] int not null check ([Year] between 1 and 5),
	[DepartmentId] int not null
)
go

create table [GroupsCurators]
(
	[Id] int not null identity(1, 1) primary key,
	[CuratorId] int not null,
	[GroupId] int not null
)
go

create table [GroupsLectures]
(
	[Id] int not null identity(1, 1) primary key,
	[GroupId] int not null,
	[LectureId] int not null
)
go

create table [Heads]
(
	[Id] int not null identity(1, 1) primary key,
	[TeacherId] int not null
)
go

create table [LectureRooms]
(
	[Id] int not null identity(1, 1) primary key,
	[Building] int not null check ([Building] between 1 and 5),
	[Name] nvarchar(10) not null unique check ([Name] <> N'')
)
go

create table [Lectures]
(
	[Id] int not null identity(1, 1) primary key,
	[SubjectId] int not null,
	[TeacherId] int not null
)
go

create table [Schedules]
(
	[Id] int not null identity(1, 1) primary key,
	[Class] int not null check ([Class] between 1 and 8),
	[DayOfWeek] int not null check ([DayOfWeek] between 1 and 7),
	[Week] int not null check ([Week] between 1 and 52),
	[LectureId] int not null,
	[LectureRoomId] int not null
)
go

create table [Subjects]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(100) not null unique check ([Name] <> N'')
)
go

create table [Teachers]
(
	[Id] int not null identity(1, 1) primary key,
	[Name] nvarchar(max) not null check ([Name] <> N''),
	[Surname] nvarchar(max) not null check ([Surname] <> N'')
)
go

alter table [Assistants]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

alter table [Curators]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

alter table [Deans]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

alter table [Departments]
add foreign key ([FacultyId]) references [Faculties]([Id])
go

alter table [Departments]
add foreign key ([HeadId]) references [Heads]([Id])
go

alter table [Faculties]
add foreign key ([DeanId]) references [Deans]([Id])
go

alter table [Groups]
add foreign key ([DepartmentId]) references [Departments]([Id])
go

alter table [GroupsCurators]
add foreign key ([CuratorId]) references [Curators]([Id])
go

alter table [GroupsCurators]
add foreign key ([GroupId]) references [Groups]([Id])
go

alter table [GroupsLectures]
add foreign key ([GroupId]) references [Groups]([Id])
go

alter table [GroupsLectures]
add foreign key ([LectureId]) references [Lectures]([Id])
go

alter table [Heads]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

alter table [Lectures]
add foreign key ([SubjectId]) references [Subjects]([Id])
go

alter table [Lectures]
add foreign key ([TeacherId]) references [Teachers]([Id])
go

alter table [Schedules]
add foreign key ([LectureId]) references [Lectures]([Id])
go

alter table [Schedules]
add foreign key ([LectureRoomId]) references [LectureRooms]([Id])
go

-- ¬ывести названи€ аудиторий, в которых читает лекции преподаватель УEdward HopperФ.
SELECT LR.Name
FROM Lectures AS L
JOIN Schedules AS S ON L.Id = S.LectureId
JOIN LectureRooms AS LR ON S.LectureRoomId = LR.Id
JOIN Teachers AS T ON L.TeacherId = T.Id
WHERE T.Name = 'Edward Hopper'

-- ¬ывести фамилии ассистентов, читающих лекции в группе УF505Ф.
SELECT DISTINCT T.Surname
FROM Assistants AS A
JOIN Lectures AS L ON A.TeacherId = L.TeacherId
JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
JOIN Groups AS G ON GL.GroupId = G.Id
JOIN Teachers AS T ON A.TeacherId = T.Id
WHERE G.Name = 'F505'

-- ¬ывести дисциплины, которые читает преподаватель УAlex CarmackФ дл€ групп 5-го курса.
SELECT DISTINCT S.Name
FROM Lectures AS L
JOIN Subjects AS S ON L.SubjectId = S.Id
JOIN GroupsLectures AS GL ON L.Id = GL.LectureId
JOIN Groups AS G ON GL.GroupId = G.Id
JOIN Teachers AS T ON L.TeacherId = T.Id
WHERE T.Name = 'Alex Carmack' AND G.Year = 5

-- ¬ывести фамилии преподавателей, которые не читают лекции по понедельникам.
SELECT DISTINCT T.Surname
FROM Teachers AS T
LEFT JOIN Lectures AS L ON T.Id = L.TeacherId
LEFT JOIN Schedules AS S ON L.Id = S.LectureId
WHERE S.DayOfWeek <> 1 OR S.DayOfWeek IS NULL

-- ¬ывести названи€ аудиторий, с указанием их корпусов, в которых нет лекций в среду второй недели на третьей паре.
SELECT LR.Name, LR.Building
FROM LectureRooms AS LR
WHERE LR.Id NOT IN (
    SELECT DISTINCT S.LectureRoomId
    FROM Schedules AS S
    JOIN Lectures AS L ON S.LectureId = L.Id
    JOIN Subjects AS Sub ON L.SubjectId = Sub.Id
    WHERE S.DayOfWeek = 3 AND S.Week = 2 AND S.Class = 3
)
-- ¬ывести полные имена преподавателей факультета УComputer ScienceФ, которые не курируют группы кафедры УSoftware DevelopmentФ.
SELECT DISTINCT T.Name, T.Surname
FROM Teachers AS T
JOIN Departments AS D ON T.Id = D.HeadId
JOIN Faculties AS F ON D.FacultyId = F.Id
LEFT JOIN Curators AS C ON T.Id = C.TeacherId
LEFT JOIN Groups AS G ON C.Id = G.Id
WHERE F.Name = 'Computer Science' AND G.Id IS NULL

-- ¬ывести список номеров всех корпусов, которые имеютс€ в таблицах факультетов, кафедр и аудиторий.
SELECT DISTINCT Building
FROM (
    SELECT Building FROM Faculties
    UNION
    SELECT Building FROM Departments
    UNION
    SELECT Building FROM LectureRooms
) AS Buildings

-- ¬ывести полные имена преподавателей в следующем пор€дке: деканы факультетов, заведующие кафедрами, преподаватели, кураторы, ассистенты.
SELECT Name, Surname, 'Dean' AS Position
FROM Deans
JOIN Teachers ON Deans.TeacherId = Teachers.Id
UNION
SELECT Name, Surname, 'Department Head' AS Position
FROM Heads
JOIN Teachers ON Heads.TeacherId = Teachers.Id
UNION
SELECT Name, Surname, 'Teacher' AS Position
FROM Teachers
UNION
SELECT T.Name, T.Surname, 'Curator' AS Position
FROM Curators AS C
JOIN Teachers AS T ON C.TeacherId = T.Id
UNION
SELECT T.Name, T.Surname, 'Assistant' AS Position
FROM Assistants AS A
JOIN Teachers AS T ON A.TeacherId = T.Id

-- ¬ывести дни недели (без повторений), в которые имеютс€ зан€ти€ в аудитори€х УA311Ф и УA104Ф корпуса 6.
SELECT DISTINCT Building
FROM (
    SELECT Building FROM Faculties
    UNION
    SELECT Building FROM Departments
    UNION
    SELECT Building FROM LectureRooms
) AS Buildings
