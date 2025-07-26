drop table evBook;
drop table parkingWaitList;
drop table parkingInfo;
drop table loginInfo;
drop table employeeInfo;
drop table departmentInfo;
drop table buildingInfo;

select table_name from user_tables;

create table buildingInfo(
    buildingId int not null,
    buildingName varchar(30) not null,
    parkingSpace int not null,
    primary key (buildingId)
);

create table departmentInfo(
    departmentId int not null,
    departmentName varchar(30) not null,
    buildingId int not null,
    primary key (departmentId),
    foreign key (buildingId) references buildingInfo
    ON DELETE CASCADE
);

create table employeeInfo(
    employeeId int not null,
    firstName varchar(30) not null,
    lastName varchar(30) not null,
    employeeStatus varchar(2) not null,
    departmentId int not null,
    age int not null,
    primary key (employeeId),
    foreign key (departmentId) references departmentInfo
    ON DELETE CASCADE
);

create table loginInfo(
    employeeId int not null,
    userName varchar(30) not null,
    passWord varchar(30) not null,
    bookingAuth int not null,
    adminAuth int not null,
    primary key (userName),
    foreign key (employeeId) references employeeInfo
    ON DELETE CASCADE
);

create table parkingInfo(
    parkingNum int not null,
    employeeId int null,
    evCharge int not null,
    tempAssign int not null,
    fastCharge int not null,
    primary key (parkingNum),
    foreign key (employeeId) references employeeInfo
    ON DELETE CASCADE
);

create table EVbook(
    bookId int not null,
    parkingNum int not null,
    employeeId int not null,
    bookingDate char(20) not null,
    startTime char(20) not null,
    primary key (bookId),
    foreign key (parkingNum) references parkingInfo ON DELETE CASCADE,
    foreign key (employeeId) references employeeInfo ON DELETE CASCADE
);

create table parkingWaitList(
    waitListId int not null,
    employeeId int not null,
    waitFrom char(20) not null,
    parkingNum int null,
    primary key (waitListId),
    foreign key (employeeId) references employeeInfo ON DELETE CASCADE,
    foreign key (parkingNum) references parkingInfo ON DELETE CASCADE
);

-- insert dummy data
-- buildingInfo dummy data
insert into buildingInfo
values(1, 'Executive Office', 25);

insert into buildingInfo
values(2, 'Administration Office', 60);

insert into buildingInfo
values(3, 'Cafeteria Building', 15);

insert into buildingInfo
values(4, 'IT Office', 35);

insert into buildingInfo
values(5, 'Warehouse', 6);

insert into buildingInfo
values(6, 'Distribution Centre', 30);

insert into buildingInfo
values(7, 'Visiting Parking Lot A', 60);

insert into buildingInfo
values(8, 'Visiting Parking Lot B', 10);

-- departmentInfo dummy data
insert into departmentInfo
values (1, 'Executive Department', 1);

insert into departmentInfo
values (2, 'Chairman Office', 1);

insert into departmentInfo
values (3, 'Marketing Department', 1);

insert into departmentInfo
values (4, 'Human Resources', 1);

insert into departmentInfo
values (5, 'Finance Department', 2);

insert into departmentInfo
values (6, 'CFO Office', 2);

insert into departmentInfo
values (7, 'Cafeteria', 3);

insert into departmentInfo
values (8, 'IT Admin', 4);

insert into departmentInfo
values (9, 'IT Procurement', 4);

insert into departmentInfo
values (10, 'IT Suport', 4);

insert into departmentInfo
values (11, 'Warehouse Department', 5);

insert into departmentInfo
values (12, 'Distribution Department', 6);

-- employeeInfo dummy data
insert into employeeInfo
values (1, 'Sharon', 'Hsu', 'FT', 1, 55);

insert into employeeInfo
values (2, 'Jimmy', 'Lee', 'FT', 2, 35);

insert into employeeInfo
values (3, 'Tom', 'Ford', 'FT', 3, 35);

insert into employeeInfo
values (4, 'Deva', 'Reeb', 'FT', 3, 45);

insert into employeeInfo
values (5, 'Joe', 'Woodward', 'FT', 4, 37);

insert into employeeInfo
values (6, 'Jess', 'Paulsen', 'FT', 4, 34 );

insert into employeeInfo
values (7, 'Bailey', 'Harambe', 'FT', 5, 55);

insert into employeeInfo
values (8, 'Yoshino', 'Belli', 'FT', 5, 27);

insert into employeeInfo
values (9, 'Sabrina', 'Zhang', 'FT', 6, 39);

insert into employeeInfo
values (10, 'Michelle', 'Choi', 'PT', 7, 42);

insert into employeeInfo
values (11, 'Sayo', 'Yoshida', 'FT', 8,35);

insert into employeeInfo
values (12, 'Daiane', 'Meneghel', 'FT', 9, 56);

insert into employeeInfo
values (13, 'Alaa', 'Othman', 'FT', 10,35);

insert into employeeInfo
values (14, 'Eden', 'Kai', 'FT', 11,32);

insert into employeeInfo
values (15, 'Jeanne', 'Cadieu', 'PT', 11, 35);

insert into employeeInfo
values (16, 'Kenshi', 'Okada', 'FT', 11, 37);

insert into employeeInfo
values (17, 'Sanne', 'Vloet', 'FT', 11,22);

insert into employeeInfo
values (18, 'Farida', 'Agzamova', 'FT', 12,25);

insert into employeeInfo
values (19, 'Fernanda', 'Liz', 'FT', 2, 26);

insert into employeeInfo
values (20, 'Adele', 'Farine', 'FT', 1,29);

insert into employeeInfo
values (21, 'Jeanni', 'Mulder', 'FT', 12 ,35);

insert into employeeInfo
values (22, 'Solange', 'Smith', 'FT', 11, 32);

insert into employeeInfo
values (23, 'Roy', 'Kim', 'FT', 3, 55);

insert into employeeInfo
values (24, 'Kyle', 'Chalmers', 'FT', 9, 35);

insert into employeeInfo
values (25, 'Eric', 'Mcdonald', 'FT', 10, 34);

insert into employeeInfo
values (26, 'Colin', 'Newton', 'FT', 11, 26);

insert into employeeInfo
values (27, 'Leonard', 'Lim', 'FT', 5, 55);

insert into employeeInfo
values (28, 'Lucie', 'Mahe', 'FT', 7, 35);

insert into employeeInfo
values (29, 'Jim', 'Parsons', 'FT', 12, 36);

insert into employeeInfo
values (30, 'Patti', 'Wagner', 'FT', 12, 23);

-- employeeInfo dummy data
insert into parkingInfo
values (1, NULL,1, 1, 1);

insert into parkingInfo
values (2, NULL,1, 1, 1);

insert into parkingInfo
values (3, NULL,1, 1, 0);

insert into parkingInfo
values (4, NULL,1, 1, 0);

insert into parkingInfo
values (5, NULL,1, 1, 0);

insert into parkingInfo
values (6, NULL,1, 1, 0);

insert into parkingInfo
values (8, NULL,0, 0, 0);

insert into parkingInfo
values (9, NULL,0, 0, 0);

insert into parkingInfo
values (10, NULL,0, 0, 0);

insert into parkingInfo
values (11, NULL,0, 0, 0);

insert into parkingInfo
values (12, NULL,0, 0, 0);

insert into parkingInfo
values (60, 1, 0, 0, 0);

insert into parkingInfo
values (61, 2, 0, 0, 0);

insert into parkingInfo
values (65, 3, 0, 0, 0);

insert into parkingInfo
values (66, 4, 0, 0, 0);

insert into parkingInfo
values (67, 5, 0, 0, 0);

insert into parkingInfo
values (68, 6, 0, 0, 0);

insert into parkingInfo
values (69, 7, 0, 0, 0);

insert into parkingInfo
values (70, 8, 0, 0, 0);

insert into parkingInfo
values (75, 9, 0, 0, 0);

insert into parkingInfo
values (76, 10, 0, 0, 0);

insert into parkingInfo
values (90, 11, 0, 0, 0);

insert into parkingInfo
values (91, 12, 0, 0, 0);

insert into parkingInfo
values (92, 13, 0, 0, 0);

insert into parkingInfo
values (93, 14, 0, 0, 0);

-- parkingWaitList dummy data
insert into parkingWaitList
values (1, 11, '2017-01-01', 90);

insert into parkingWaitList
values (2, 12, '2017-01-01', 91);

insert into parkingWaitList
values (3, 13, '2017-02-01', 92);

insert into parkingWaitList
values (4, 14, '2017-02-01', 93);

insert into parkingWaitList
values (5, 15, '2017-02-15', NULL);

insert into parkingWaitList
values (6, 16, '2017-03-17', NULL);

insert into parkingWaitList
values (7, 17, '2017-04-17', NULL);

insert into parkingWaitList
values (8, 18, '2017-07-17', NULL);

insert into parkingWaitList
values (9, 19, '2017-08-12', NULL);

insert into parkingWaitList
values (10, 20, '2018-02-17', NULL);

-- loginInfo dummy data
insert into loginInfo
values (1, 'sharon', '6sa483er6w', 1, 1);

insert into loginInfo
values (2, 'jimmy', 'swa3r15e', 1, 1);

insert into loginInfo
values (3, 'tom', 'asre2w52', 1, 1);

insert into loginInfo
values (4, 'deva', '2sdrwea3', 1, 0);

insert into loginInfo
values (5, 'joe', 'asdf3234', 1, 0);

insert into loginInfo
values (6, 'jess', 'ghdsfgwe2', 1, 1);

insert into loginInfo
values (7, 'bailey', 'sde32253sfd', 1, 0);

insert into loginInfo
values (8, 'yoshino', 'sae3223', 1, 0);

insert into loginInfo
values (9, 'sabrina', 'ag3e22', 1, 0);

insert into loginInfo
values (10, 'michelle', '3wq2153w', 1, 0);

insert into loginInfo
values (11, 'sayo', 'asd32ge3w', 1, 0);

insert into loginInfo
values (12, 'daiane', 'gfdher245', 1, 0);

insert into loginInfo
values (13, 'alaa', '35a4e25', 1, 0);

insert into loginInfo
values (14, 'eden', 'gsd32reawe', 1, 0);

insert into loginInfo
values (15, 'jeanne', 'gae.245w3', 1, 0);

insert into loginInfo
values (16, 'kenshi', 'gaw3e53wa', 1, 0);

insert into loginInfo
values (17, 'sanne', 'vz325et1ea', 1, 0);

insert into loginInfo
values (18, 'farida', 'a3we52r15t', 1, 0);

insert into loginInfo
values (19, 'fernanda', 'gaw3e21tg', 1, 0);

insert into loginInfo
values (20, 'adele', 'zsed32te', 1, 0);

insert into loginInfo
values (21, 'jeanni', 'zse3t21wea', 1, 0);

insert into loginInfo
values (22, 'solange', '3zs5et1e', 1, 0);

insert into loginInfo
values (23, 'roy', 'z35estg', 1, 0);

insert into loginInfo
values (24, 'kyle', 'f23es5et', 1, 0);

insert into loginInfo
values (25, 'eric', 'fews3ae2tgyh', 1, 0);

insert into loginInfo
values (26, 'colin', 'hsd3r52te', 1, 0);

insert into loginInfo
values (27, 'leonard', 'ewat3es2s', 1, 0);

insert into loginInfo
values (28, 'lucie', 'zv3ed5yesz', 1, 0);

insert into loginInfo
values (29, 'jim', 'z35de2t1ayh', 1, 0);

insert into loginInfo
values (30, 'patti', 'vbsz3ed2t', 1, 0);


-- evBook dummy data
insert into evBook
values (1, 1, 1, '2022-01-07', '0700');

insert into evBook
values (2, 1, 1, '2022-01-08', '0700');

insert into evBook
values (3, 1, 1, '2022-02-08', '0900');

insert into evBook
values (4, 1, 1, '2022-02-09', '0700');

insert into evBook
values (5, 1, 1, '2022-02-10', '1400');

insert into evBook
values (6, 2, 2, '2022-02-08', '0700');

insert into evBook
values (7, 2, 6, '2022-03-08', '0700');

insert into evBook
values (8, 1, 7, '2022-04-08', '0700');

insert into evBook
values (9, 1, 8, '2022-03-08', '0700');

insert into evBook
values (10, 3, 8, '2022-04-08', '0700');

-- grant public accesss
grant select on buildingInfo to public;
grant select on evBook to public;
grant select on employeeInfo to public;
grant select on parkingInfo to public;
grant select on parkingWaitList to public;
grant select on loginInfo to public;
grant select on departmentInfo to public;