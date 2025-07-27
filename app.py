#!/usr/bin/env python3
"""
Parking Database Management System
SQLite Database Setup Tool

This script is for local development only.
School server uses static HTML interface due to restrictions:
- No sudo access
- Port 80 only
- No server-side scripting after course completion
"""

import sqlite3
import os
import sys

DB_FILE = "parking.db"

def init_database():
    """Initialize SQLite database with schema and sample data"""
    print("Parking Database Management System - Database Setup")
    print("==================================================")
    print("")
    
    if os.path.exists(DB_FILE):
        print(f"Database {DB_FILE} already exists.")
        response = input("Do you want to recreate it? (y/n): ")
        if response.lower() != 'y':
            print("Setup cancelled.")
            return
        os.remove(DB_FILE)
    
    print("Creating SQLite database...")
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    # Create tables (SQLite compatible)
    cursor.executescript('''
    CREATE TABLE buildingInfo(
        buildingId INTEGER PRIMARY KEY,
        buildingName TEXT NOT NULL,
        parkingSpace INTEGER NOT NULL
    );

    CREATE TABLE departmentInfo(
        departmentId INTEGER PRIMARY KEY,
        departmentName TEXT NOT NULL,
        buildingId INTEGER NOT NULL,
        FOREIGN KEY (buildingId) REFERENCES buildingInfo(buildingId)
    );

    CREATE TABLE employeeInfo(
        employeeId INTEGER PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        employeeStatus TEXT NOT NULL,
        departmentId INTEGER NOT NULL,
        age INTEGER NOT NULL,
        FOREIGN KEY (departmentId) REFERENCES departmentInfo(departmentId)
    );

    CREATE TABLE loginInfo(
        userName TEXT PRIMARY KEY,
        employeeId INTEGER NOT NULL,
        passWord TEXT NOT NULL,
        bookingAuth INTEGER NOT NULL,
        adminAuth INTEGER NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
    );

    CREATE TABLE parkingInfo(
        parkingNum INTEGER PRIMARY KEY,
        employeeId INTEGER,
        evCharge INTEGER NOT NULL,
        tempAssign INTEGER NOT NULL,
        fastCharge INTEGER NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
    );

    CREATE TABLE evBook(
        bookId INTEGER PRIMARY KEY,
        parkingNum INTEGER NOT NULL,
        employeeId INTEGER NOT NULL,
        bookingDate TEXT NOT NULL,
        startTime TEXT NOT NULL,
        FOREIGN KEY (parkingNum) REFERENCES parkingInfo(parkingNum),
        FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
    );

    CREATE TABLE parkingWaitList(
        waitListId INTEGER PRIMARY KEY,
        employeeId INTEGER NOT NULL,
        waitFrom TEXT NOT NULL,
        parkingNum INTEGER,
        FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId),
        FOREIGN KEY (parkingNum) REFERENCES parkingInfo(parkingNum)
    );
    ''')
    
    # Insert sample data
    cursor.executescript('''
    -- Building data
    INSERT INTO buildingInfo VALUES(1, 'Executive Office', 25);
    INSERT INTO buildingInfo VALUES(2, 'Administration Office', 60);
    INSERT INTO buildingInfo VALUES(3, 'Cafeteria Building', 15);
    INSERT INTO buildingInfo VALUES(4, 'IT Office', 35);

    -- Department data
    INSERT INTO departmentInfo VALUES(1, 'Executive Department', 1);
    INSERT INTO departmentInfo VALUES(2, 'Chairman Office', 1);
    INSERT INTO departmentInfo VALUES(3, 'Marketing Department', 1);
    INSERT INTO departmentInfo VALUES(4, 'Human Resources', 1);
    INSERT INTO departmentInfo VALUES(5, 'Finance Department', 2);

    -- Employee data
    INSERT INTO employeeInfo VALUES(1, 'Sharon', 'Hsu', 'FT', 1, 55);
    INSERT INTO employeeInfo VALUES(2, 'Jimmy', 'Lee', 'FT', 2, 35);
    INSERT INTO employeeInfo VALUES(3, 'Tom', 'Ford', 'FT', 3, 35);
    INSERT INTO employeeInfo VALUES(4, 'Deva', 'Reeb', 'FT', 3, 45);
    INSERT INTO employeeInfo VALUES(5, 'Joe', 'Woodward', 'FT', 4, 37);
    INSERT INTO employeeInfo VALUES(6, 'Jack', 'Dorsey', 'FT', 5, 45);
    INSERT INTO employeeInfo VALUES(7, 'Liz', 'Taylor', 'FT', 5, 58);
    INSERT INTO employeeInfo VALUES(8, 'Kelly', 'Clarkson', 'FT', 1, 48);
    INSERT INTO employeeInfo VALUES(9, 'Tyler', 'Perry', 'FT', 3, 50);
    INSERT INTO employeeInfo VALUES(10, 'Andy', 'Reeb', 'FT', 4, 33);
    INSERT INTO employeeInfo VALUES(11, 'Joe', 'Biden', 'PT', 1, 25);
    INSERT INTO employeeInfo VALUES(12, 'Donald', 'Trump', 'PT', 3, 22);
    INSERT INTO employeeInfo VALUES(13, 'Michelle', 'Obama', 'PT', 2, 20);
    INSERT INTO employeeInfo VALUES(14, 'Nicole', 'Kidman', 'PT', 2, 23);
    INSERT INTO employeeInfo VALUES(15, 'Mary', 'Brown', 'PT', 1, 25);

    -- Parking spots (150 total)
    INSERT INTO parkingInfo VALUES(1, NULL, 1, 1, 1);
    INSERT INTO parkingInfo VALUES(2, NULL, 1, 1, 1);
    INSERT INTO parkingInfo VALUES(3, NULL, 1, 1, 0);
    INSERT INTO parkingInfo VALUES(4, NULL, 1, 0, 1);
    INSERT INTO parkingInfo VALUES(5, NULL, 1, 0, 0);
    -- Continue with more parking spots...
    INSERT INTO parkingInfo VALUES(60, 1, 0, 0, 0);
    INSERT INTO parkingInfo VALUES(61, 2, 0, 0, 0);
    INSERT INTO parkingInfo VALUES(62, 3, 0, 0, 0);
    INSERT INTO parkingInfo VALUES(63, 4, 0, 0, 0);
    INSERT INTO parkingInfo VALUES(64, 5, 0, 0, 0);

    -- Waitlist entries
    INSERT INTO parkingWaitList VALUES(1, 11, '2024-01-15', NULL);
    INSERT INTO parkingWaitList VALUES(2, 12, '2024-01-20', NULL);
    INSERT INTO parkingWaitList VALUES(3, 13, '2024-02-01', NULL);

    -- Login info
    INSERT INTO loginInfo VALUES('sharon.hsu', 1, 'password123', 1, 1);
    INSERT INTO loginInfo VALUES('jimmy.lee', 2, 'password123', 1, 0);
    INSERT INTO loginInfo VALUES('joe.woodward', 5, 'password123', 1, 0);
    ''')
    
    conn.commit()
    conn.close()
    
    print("")
    print("Database created successfully!")
    print(f"Location: {os.path.abspath(DB_FILE)}")
    print("")
    print("To verify the database:")
    print(f"  sqlite3 {DB_FILE}")
    print("  sqlite> .tables")
    print("  sqlite> SELECT * FROM employeeInfo;")
    print("  sqlite> .quit")
    print("")
    print("For school server deployment:")
    print("  1. Run ./setup-school.sh")
    print("  2. Access the static HTML interface")
    print("  3. Use generated SQL with sqlite3")

def main():
    """Main function"""
    print("This script creates a local SQLite database for development.")
    print("For school server deployment, use setup-school.sh instead.")
    print("")
    
    init_database()

if __name__ == "__main__":
    main()