-- SQLite schema for Parking Management System
-- Converted from Oracle SQL for local deployment

-- Drop existing tables
DROP TABLE IF EXISTS evBook;
DROP TABLE IF EXISTS parkingWaitList;
DROP TABLE IF EXISTS parkingInfo;
DROP TABLE IF EXISTS loginInfo;
DROP TABLE IF EXISTS employeeInfo;
DROP TABLE IF EXISTS departmentInfo;
DROP TABLE IF EXISTS buildingInfo;

-- Create tables
CREATE TABLE buildingInfo(
    buildingId INTEGER PRIMARY KEY,
    buildingName TEXT NOT NULL,
    parkingSpace INTEGER NOT NULL
);

CREATE TABLE departmentInfo(
    departmentId INTEGER PRIMARY KEY,
    departmentName TEXT NOT NULL,
    buildingId INTEGER NOT NULL,
    FOREIGN KEY (buildingId) REFERENCES buildingInfo(buildingId) ON DELETE CASCADE
);

CREATE TABLE employeeInfo(
    employeeId INTEGER PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    employeeStatus TEXT NOT NULL CHECK(employeeStatus IN ('FT', 'PT')),
    departmentId INTEGER NOT NULL,
    age INTEGER NOT NULL,
    FOREIGN KEY (departmentId) REFERENCES departmentInfo(departmentId) ON DELETE CASCADE
);

CREATE TABLE loginInfo(
    employeeId INTEGER NOT NULL,
    userName TEXT PRIMARY KEY,
    passWord TEXT NOT NULL,
    bookingAuth INTEGER NOT NULL CHECK(bookingAuth IN (0, 1)),
    adminAuth INTEGER NOT NULL CHECK(adminAuth IN (0, 1)),
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId) ON DELETE CASCADE
);

CREATE TABLE parkingInfo(
    parkingNum INTEGER PRIMARY KEY,
    employeeId INTEGER,
    evCharge INTEGER NOT NULL CHECK(evCharge IN (0, 1)),
    tempAssign INTEGER NOT NULL CHECK(tempAssign IN (0, 1)),
    fastCharge INTEGER NOT NULL CHECK(fastCharge IN (0, 1)),
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId) ON DELETE CASCADE
);

CREATE TABLE evBook(
    bookId INTEGER PRIMARY KEY,
    parkingNum INTEGER NOT NULL,
    employeeId INTEGER NOT NULL,
    bookingDate TEXT NOT NULL,
    startTime TEXT NOT NULL,
    FOREIGN KEY (parkingNum) REFERENCES parkingInfo(parkingNum) ON DELETE CASCADE,
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId) ON DELETE CASCADE
);

CREATE TABLE parkingWaitList(
    waitListId INTEGER PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    waitFrom TEXT NOT NULL,
    parkingNum INTEGER,
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId) ON DELETE CASCADE,
    FOREIGN KEY (parkingNum) REFERENCES parkingInfo(parkingNum) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_dept_building ON departmentInfo(buildingId);
CREATE INDEX idx_emp_dept ON employeeInfo(departmentId);
CREATE INDEX idx_parking_emp ON parkingInfo(employeeId);
CREATE INDEX idx_ev_parking ON evBook(parkingNum);
CREATE INDEX idx_ev_emp ON evBook(employeeId);
CREATE INDEX idx_wait_emp ON parkingWaitList(employeeId);

-- Insert sample data (same as Oracle version)
-- Buildings
INSERT INTO buildingInfo VALUES(1, 'Executive Office', 25);
INSERT INTO buildingInfo VALUES(2, 'Administration Office', 60);
INSERT INTO buildingInfo VALUES(3, 'Cafeteria Building', 15);
INSERT INTO buildingInfo VALUES(4, 'IT Office', 35);
INSERT INTO buildingInfo VALUES(5, 'Warehouse', 6);
INSERT INTO buildingInfo VALUES(6, 'Distribution Centre', 30);
INSERT INTO buildingInfo VALUES(7, 'Visiting Parking Lot A', 60);
INSERT INTO buildingInfo VALUES(8, 'Visiting Parking Lot B', 10);

-- Departments
INSERT INTO departmentInfo VALUES(1, 'Executive Department', 1);
INSERT INTO departmentInfo VALUES(2, 'Chairman Office', 1);
INSERT INTO departmentInfo VALUES(3, 'Marketing Department', 1);
INSERT INTO departmentInfo VALUES(4, 'Human Resources', 1);
INSERT INTO departmentInfo VALUES(5, 'Finance Department', 2);
INSERT INTO departmentInfo VALUES(6, 'CFO Office', 2);
INSERT INTO departmentInfo VALUES(7, 'Cafeteria', 3);
INSERT INTO departmentInfo VALUES(8, 'IT Admin', 4);
INSERT INTO departmentInfo VALUES(9, 'IT Procurement', 4);
INSERT INTO departmentInfo VALUES(10, 'IT Suport', 4);
INSERT INTO departmentInfo VALUES(11, 'Warehouse Department', 5);
INSERT INTO departmentInfo VALUES(12, 'Distribution Department', 6);

-- Employees (first 10 for demo)
INSERT INTO employeeInfo VALUES(1, 'Sharon', 'Hsu', 'FT', 1, 55);
INSERT INTO employeeInfo VALUES(2, 'Jimmy', 'Lee', 'FT', 2, 35);
INSERT INTO employeeInfo VALUES(3, 'Tom', 'Ford', 'FT', 3, 35);
INSERT INTO employeeInfo VALUES(4, 'Deva', 'Reeb', 'FT', 3, 45);
INSERT INTO employeeInfo VALUES(5, 'Joe', 'Woodward', 'FT', 4, 37);
INSERT INTO employeeInfo VALUES(6, 'Jess', 'Paulsen', 'FT', 4, 34);
INSERT INTO employeeInfo VALUES(7, 'Bailey', 'Harambe', 'FT', 5, 55);
INSERT INTO employeeInfo VALUES(8, 'Yoshino', 'Belli', 'FT', 5, 27);
INSERT INTO employeeInfo VALUES(9, 'Sabrina', 'Zhang', 'FT', 6, 39);
INSERT INTO employeeInfo VALUES(10, 'Michelle', 'Choi', 'PT', 7, 42);

-- Login info for demo users
INSERT INTO loginInfo VALUES(1, 'sharon', '6sa483er6w', 1, 1);
INSERT INTO loginInfo VALUES(2, 'jimmy', 'swa3r15e', 1, 1);
INSERT INTO loginInfo VALUES(3, 'tom', 'asre2w52', 1, 1);

-- Parking assignments
INSERT INTO parkingInfo VALUES(60, 1, 0, 0, 0);
INSERT INTO parkingInfo VALUES(61, 2, 0, 0, 0);
INSERT INTO parkingInfo VALUES(65, 3, 0, 0, 0);
INSERT INTO parkingInfo VALUES(1, NULL, 1, 1, 1);
INSERT INTO parkingInfo VALUES(2, NULL, 1, 1, 1);

-- Sample waitlist
INSERT INTO parkingWaitList VALUES(1, 7, '2017-01-01', NULL);
INSERT INTO parkingWaitList VALUES(2, 8, '2017-02-01', NULL);
INSERT INTO parkingWaitList VALUES(3, 9, '2017-03-01', NULL);