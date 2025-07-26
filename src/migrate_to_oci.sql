-- Oracle Autonomous Database Migration Script for Parking Management System
-- This script is designed to work with OCI Free Tier Autonomous Database
-- 
-- Prerequisites:
-- 1. Create an Oracle Cloud account and provision an Autonomous Database (Always Free tier)
-- 2. Download the wallet file and configure SQL*Plus or SQL Developer
-- 3. Connect as ADMIN user to run this script

-- Create application user 
-- IMPORTANT: Replace this password with a strong one and store it in your .env file
-- Password must be at least 12 characters with uppercase, lowercase, numbers, and symbols
CREATE USER PARKING_APP IDENTIFIED BY "ChangeThisPassword123#!";

-- Grant necessary privileges
GRANT CREATE SESSION TO PARKING_APP;
GRANT CREATE TABLE TO PARKING_APP;
GRANT CREATE SEQUENCE TO PARKING_APP;
GRANT CREATE VIEW TO PARKING_APP;
GRANT UNLIMITED TABLESPACE TO PARKING_APP;

-- Connect as PARKING_APP user before running the rest of the script
-- CONNECT PARKING_APP/YourStrongPassword123#@your_tns_name

-- Drop existing tables if they exist (for clean migration)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE evBook CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE parkingWaitList CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE parkingInfo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE loginInfo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE employeeInfo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE departmentInfo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE buildingInfo CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/

-- Create tables with proper constraints
CREATE TABLE buildingInfo(
    buildingId NUMBER(10) NOT NULL,
    buildingName VARCHAR2(30) NOT NULL,
    parkingSpace NUMBER(10) NOT NULL,
    CONSTRAINT pk_building PRIMARY KEY (buildingId)
);

CREATE TABLE departmentInfo(
    departmentId NUMBER(10) NOT NULL,
    departmentName VARCHAR2(30) NOT NULL,
    buildingId NUMBER(10) NOT NULL,
    CONSTRAINT pk_department PRIMARY KEY (departmentId),
    CONSTRAINT fk_dept_building FOREIGN KEY (buildingId) 
        REFERENCES buildingInfo(buildingId) ON DELETE CASCADE
);

CREATE TABLE employeeInfo(
    employeeId NUMBER(10) NOT NULL,
    firstName VARCHAR2(30) NOT NULL,
    lastName VARCHAR2(30) NOT NULL,
    employeeStatus VARCHAR2(2) NOT NULL,
    departmentId NUMBER(10) NOT NULL,
    age NUMBER(3) NOT NULL,
    CONSTRAINT pk_employee PRIMARY KEY (employeeId),
    CONSTRAINT fk_emp_dept FOREIGN KEY (departmentId) 
        REFERENCES departmentInfo(departmentId) ON DELETE CASCADE,
    CONSTRAINT chk_status CHECK (employeeStatus IN ('FT', 'PT'))
);

CREATE TABLE loginInfo(
    employeeId NUMBER(10) NOT NULL,
    userName VARCHAR2(30) NOT NULL,
    passWord VARCHAR2(30) NOT NULL,
    bookingAuth NUMBER(1) NOT NULL,
    adminAuth NUMBER(1) NOT NULL,
    CONSTRAINT pk_login PRIMARY KEY (userName),
    CONSTRAINT fk_login_emp FOREIGN KEY (employeeId) 
        REFERENCES employeeInfo(employeeId) ON DELETE CASCADE,
    CONSTRAINT chk_booking CHECK (bookingAuth IN (0, 1)),
    CONSTRAINT chk_admin CHECK (adminAuth IN (0, 1))
);

CREATE TABLE parkingInfo(
    parkingNum NUMBER(10) NOT NULL,
    employeeId NUMBER(10) NULL,
    evCharge NUMBER(1) NOT NULL,
    tempAssign NUMBER(1) NOT NULL,
    fastCharge NUMBER(1) NOT NULL,
    CONSTRAINT pk_parking PRIMARY KEY (parkingNum),
    CONSTRAINT fk_parking_emp FOREIGN KEY (employeeId) 
        REFERENCES employeeInfo(employeeId) ON DELETE CASCADE,
    CONSTRAINT chk_ev CHECK (evCharge IN (0, 1)),
    CONSTRAINT chk_temp CHECK (tempAssign IN (0, 1)),
    CONSTRAINT chk_fast CHECK (fastCharge IN (0, 1))
);

CREATE TABLE EVbook(
    bookId NUMBER(10) NOT NULL,
    parkingNum NUMBER(10) NOT NULL,
    employeeId NUMBER(10) NOT NULL,
    bookingDate VARCHAR2(20) NOT NULL,
    startTime VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_evbook PRIMARY KEY (bookId),
    CONSTRAINT fk_ev_parking FOREIGN KEY (parkingNum) 
        REFERENCES parkingInfo(parkingNum) ON DELETE CASCADE,
    CONSTRAINT fk_ev_emp FOREIGN KEY (employeeId) 
        REFERENCES employeeInfo(employeeId) ON DELETE CASCADE
);

CREATE TABLE parkingWaitList(
    waitListId NUMBER(10) NOT NULL,
    employeeId NUMBER(10) NOT NULL,
    waitFrom VARCHAR2(20) NOT NULL,
    parkingNum NUMBER(10) NULL,
    CONSTRAINT pk_waitlist PRIMARY KEY (waitListId),
    CONSTRAINT fk_wait_emp FOREIGN KEY (employeeId) 
        REFERENCES employeeInfo(employeeId) ON DELETE CASCADE,
    CONSTRAINT fk_wait_parking FOREIGN KEY (parkingNum) 
        REFERENCES parkingInfo(parkingNum) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_dept_building ON departmentInfo(buildingId);
CREATE INDEX idx_emp_dept ON employeeInfo(departmentId);
CREATE INDEX idx_parking_emp ON parkingInfo(employeeId);
CREATE INDEX idx_ev_parking ON EVbook(parkingNum);
CREATE INDEX idx_ev_emp ON EVbook(employeeId);
CREATE INDEX idx_wait_emp ON parkingWaitList(employeeId);

-- Insert sample data
-- Building Information
INSERT INTO buildingInfo VALUES(1, 'Executive Office', 25);
INSERT INTO buildingInfo VALUES(2, 'Administration Office', 60);
INSERT INTO buildingInfo VALUES(3, 'Cafeteria Building', 15);
INSERT INTO buildingInfo VALUES(4, 'IT Office', 35);
INSERT INTO buildingInfo VALUES(5, 'Warehouse', 6);
INSERT INTO buildingInfo VALUES(6, 'Distribution Centre', 30);
INSERT INTO buildingInfo VALUES(7, 'Visiting Parking Lot A', 60);
INSERT INTO buildingInfo VALUES(8, 'Visiting Parking Lot B', 10);

-- Department Information
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

-- Employee Information
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
INSERT INTO employeeInfo VALUES(11, 'Sayo', 'Yoshida', 'FT', 8, 35);
INSERT INTO employeeInfo VALUES(12, 'Daiane', 'Meneghel', 'FT', 9, 56);
INSERT INTO employeeInfo VALUES(13, 'Alaa', 'Othman', 'FT', 10, 35);
INSERT INTO employeeInfo VALUES(14, 'Eden', 'Kai', 'FT', 11, 32);
INSERT INTO employeeInfo VALUES(15, 'Jeanne', 'Cadieu', 'PT', 11, 35);
INSERT INTO employeeInfo VALUES(16, 'Kenshi', 'Okada', 'FT', 11, 37);
INSERT INTO employeeInfo VALUES(17, 'Sanne', 'Vloet', 'FT', 11, 22);
INSERT INTO employeeInfo VALUES(18, 'Farida', 'Agzamova', 'FT', 12, 25);
INSERT INTO employeeInfo VALUES(19, 'Fernanda', 'Liz', 'FT', 2, 26);
INSERT INTO employeeInfo VALUES(20, 'Adele', 'Farine', 'FT', 1, 29);
INSERT INTO employeeInfo VALUES(21, 'Jeanni', 'Mulder', 'FT', 12, 35);
INSERT INTO employeeInfo VALUES(22, 'Solange', 'Smith', 'FT', 11, 32);
INSERT INTO employeeInfo VALUES(23, 'Roy', 'Kim', 'FT', 3, 55);
INSERT INTO employeeInfo VALUES(24, 'Kyle', 'Chalmers', 'FT', 9, 35);
INSERT INTO employeeInfo VALUES(25, 'Eric', 'Mcdonald', 'FT', 10, 34);
INSERT INTO employeeInfo VALUES(26, 'Colin', 'Newton', 'FT', 11, 26);
INSERT INTO employeeInfo VALUES(27, 'Leonard', 'Lim', 'FT', 5, 55);
INSERT INTO employeeInfo VALUES(28, 'Lucie', 'Mahe', 'FT', 7, 35);
INSERT INTO employeeInfo VALUES(29, 'Jim', 'Parsons', 'FT', 12, 36);
INSERT INTO employeeInfo VALUES(30, 'Patti', 'Wagner', 'FT', 12, 23);

-- Parking Information
INSERT INTO parkingInfo VALUES(1, NULL, 1, 1, 1);
INSERT INTO parkingInfo VALUES(2, NULL, 1, 1, 1);
INSERT INTO parkingInfo VALUES(3, NULL, 1, 1, 0);
INSERT INTO parkingInfo VALUES(4, NULL, 1, 1, 0);
INSERT INTO parkingInfo VALUES(5, NULL, 1, 1, 0);
INSERT INTO parkingInfo VALUES(6, NULL, 1, 1, 0);
INSERT INTO parkingInfo VALUES(8, NULL, 0, 0, 0);
INSERT INTO parkingInfo VALUES(9, NULL, 0, 0, 0);
INSERT INTO parkingInfo VALUES(10, NULL, 0, 0, 0);
INSERT INTO parkingInfo VALUES(11, NULL, 0, 0, 0);
INSERT INTO parkingInfo VALUES(12, NULL, 0, 0, 0);
INSERT INTO parkingInfo VALUES(60, 1, 0, 0, 0);
INSERT INTO parkingInfo VALUES(61, 2, 0, 0, 0);
INSERT INTO parkingInfo VALUES(65, 3, 0, 0, 0);
INSERT INTO parkingInfo VALUES(66, 4, 0, 0, 0);
INSERT INTO parkingInfo VALUES(67, 5, 0, 0, 0);
INSERT INTO parkingInfo VALUES(68, 6, 0, 0, 0);
INSERT INTO parkingInfo VALUES(69, 7, 0, 0, 0);
INSERT INTO parkingInfo VALUES(70, 8, 0, 0, 0);
INSERT INTO parkingInfo VALUES(75, 9, 0, 0, 0);
INSERT INTO parkingInfo VALUES(76, 10, 0, 0, 0);
INSERT INTO parkingInfo VALUES(90, 11, 0, 0, 0);
INSERT INTO parkingInfo VALUES(91, 12, 0, 0, 0);
INSERT INTO parkingInfo VALUES(92, 13, 0, 0, 0);
INSERT INTO parkingInfo VALUES(93, 14, 0, 0, 0);

-- Parking Wait List
INSERT INTO parkingWaitList VALUES(1, 11, '2017-01-01', 90);
INSERT INTO parkingWaitList VALUES(2, 12, '2017-01-01', 91);
INSERT INTO parkingWaitList VALUES(3, 13, '2017-02-01', 92);
INSERT INTO parkingWaitList VALUES(4, 14, '2017-02-01', 93);
INSERT INTO parkingWaitList VALUES(5, 15, '2017-02-15', NULL);
INSERT INTO parkingWaitList VALUES(6, 16, '2017-03-17', NULL);
INSERT INTO parkingWaitList VALUES(7, 17, '2017-04-17', NULL);
INSERT INTO parkingWaitList VALUES(8, 18, '2017-07-17', NULL);
INSERT INTO parkingWaitList VALUES(9, 19, '2017-08-12', NULL);
INSERT INTO parkingWaitList VALUES(10, 20, '2018-02-17', NULL);

-- Login Information
INSERT INTO loginInfo VALUES(1, 'sharon', '6sa483er6w', 1, 1);
INSERT INTO loginInfo VALUES(2, 'jimmy', 'swa3r15e', 1, 1);
INSERT INTO loginInfo VALUES(3, 'tom', 'asre2w52', 1, 1);
INSERT INTO loginInfo VALUES(4, 'deva', '2sdrwea3', 1, 0);
INSERT INTO loginInfo VALUES(5, 'joe', 'asdf3234', 1, 0);
INSERT INTO loginInfo VALUES(6, 'jess', 'ghdsfgwe2', 1, 1);
INSERT INTO loginInfo VALUES(7, 'bailey', 'sde32253sfd', 1, 0);
INSERT INTO loginInfo VALUES(8, 'yoshino', 'sae3223', 1, 0);
INSERT INTO loginInfo VALUES(9, 'sabrina', 'ag3e22', 1, 0);
INSERT INTO loginInfo VALUES(10, 'michelle', '3wq2153w', 1, 0);
INSERT INTO loginInfo VALUES(11, 'sayo', 'asd32ge3w', 1, 0);
INSERT INTO loginInfo VALUES(12, 'daiane', 'gfdher245', 1, 0);
INSERT INTO loginInfo VALUES(13, 'alaa', '35a4e25', 1, 0);
INSERT INTO loginInfo VALUES(14, 'eden', 'gsd32reawe', 1, 0);
INSERT INTO loginInfo VALUES(15, 'jeanne', 'gae.245w3', 1, 0);
INSERT INTO loginInfo VALUES(16, 'kenshi', 'gaw3e53wa', 1, 0);
INSERT INTO loginInfo VALUES(17, 'sanne', 'vz325et1ea', 1, 0);
INSERT INTO loginInfo VALUES(18, 'farida', 'a3we52r15t', 1, 0);
INSERT INTO loginInfo VALUES(19, 'fernanda', 'gaw3e21tg', 1, 0);
INSERT INTO loginInfo VALUES(20, 'adele', 'zsed32te', 1, 0);
INSERT INTO loginInfo VALUES(21, 'jeanni', 'zse3t21wea', 1, 0);
INSERT INTO loginInfo VALUES(22, 'solange', '3zs5et1e', 1, 0);
INSERT INTO loginInfo VALUES(23, 'roy', 'z35estg', 1, 0);
INSERT INTO loginInfo VALUES(24, 'kyle', 'f23es5et', 1, 0);
INSERT INTO loginInfo VALUES(25, 'eric', 'fews3ae2tgyh', 1, 0);
INSERT INTO loginInfo VALUES(26, 'colin', 'hsd3r52te', 1, 0);
INSERT INTO loginInfo VALUES(27, 'leonard', 'ewat3es2s', 1, 0);
INSERT INTO loginInfo VALUES(28, 'lucie', 'zv3ed5yesz', 1, 0);
INSERT INTO loginInfo VALUES(29, 'jim', 'z35de2t1ayh', 1, 0);
INSERT INTO loginInfo VALUES(30, 'patti', 'vbsz3ed2t', 1, 0);

-- EV Booking Information
INSERT INTO evBook VALUES(1, 1, 1, '2022-01-07', '0700');
INSERT INTO evBook VALUES(2, 1, 1, '2022-01-08', '0700');
INSERT INTO evBook VALUES(3, 1, 1, '2022-02-08', '0900');
INSERT INTO evBook VALUES(4, 1, 1, '2022-02-09', '0700');
INSERT INTO evBook VALUES(5, 1, 1, '2022-02-10', '1400');
INSERT INTO evBook VALUES(6, 2, 2, '2022-02-08', '0700');
INSERT INTO evBook VALUES(7, 2, 6, '2022-03-08', '0700');
INSERT INTO evBook VALUES(8, 1, 7, '2022-04-08', '0700');
INSERT INTO evBook VALUES(9, 1, 8, '2022-03-08', '0700');
INSERT INTO evBook VALUES(10, 3, 8, '2022-04-08', '0700');

-- Commit all changes
COMMIT;

-- Create views for commonly used queries
CREATE OR REPLACE VIEW v_employee_parking AS
SELECT e.employeeId, e.firstName, e.lastName, e.employeeStatus,
       d.departmentName, b.buildingName, p.parkingNum
FROM employeeInfo e
JOIN departmentInfo d ON e.departmentId = d.departmentId
JOIN buildingInfo b ON d.buildingId = b.buildingId
LEFT JOIN parkingInfo p ON e.employeeId = p.employeeId;

CREATE OR REPLACE VIEW v_parking_availability AS
SELECT b.buildingName, b.parkingSpace as total_spaces,
       COUNT(p.parkingNum) as occupied_spaces,
       b.parkingSpace - COUNT(p.parkingNum) as available_spaces
FROM buildingInfo b
LEFT JOIN parkingInfo p ON p.employeeId IS NOT NULL
GROUP BY b.buildingId, b.buildingName, b.parkingSpace;

CREATE OR REPLACE VIEW v_ev_booking_details AS
SELECT ev.bookId, ev.bookingDate, ev.startTime,
       e.firstName || ' ' || e.lastName as employee_name,
       p.parkingNum, 
       CASE WHEN p.fastCharge = 1 THEN 'Fast' ELSE 'Regular' END as charge_type
FROM evBook ev
JOIN employeeInfo e ON ev.employeeId = e.employeeId
JOIN parkingInfo p ON ev.parkingNum = p.parkingNum
ORDER BY ev.bookingDate DESC, ev.startTime;

-- Grant minimal privileges for application access
-- Run these as ADMIN user after creating the views
-- GRANT SELECT, INSERT, UPDATE, DELETE ON buildingInfo TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON departmentInfo TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON employeeInfo TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON loginInfo TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON parkingInfo TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON evBook TO PARKING_APP;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON parkingWaitList TO PARKING_APP;
-- GRANT SELECT ON v_employee_parking TO PARKING_APP;
-- GRANT SELECT ON v_parking_availability TO PARKING_APP;
-- GRANT SELECT ON v_ev_booking_details TO PARKING_APP;

-- Display summary after migration
SELECT 'Migration completed successfully!' as status FROM dual;
SELECT 'Tables created: ' || COUNT(*) as table_count FROM user_tables;
SELECT table_name, num_rows FROM user_tables ORDER BY table_name;