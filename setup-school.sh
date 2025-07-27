#!/bin/bash
# School Server Setup Script for Parking Database Management System
# Works with school server restrictions: no sudo, port 80 only, sqlite3/python3/apache

echo "Parking Database Management System - School Server Setup"
echo "======================================================="
echo ""

# Check current directory
CURRENT_DIR=$(pwd)
echo "Setting up in: $CURRENT_DIR"
echo ""

# Set proper permissions for Apache
echo "1. Setting directory permissions..."
find . -type d -exec chmod 755 {} \; 2>/dev/null
find . -type f -exec chmod 644 {} \; 2>/dev/null

# Make scripts executable
chmod 755 *.sh 2>/dev/null

# Create .htaccess for Apache configuration
echo "2. Creating Apache configuration..."
cat > .htaccess << 'EOF'
# Enable directory listing
Options +Indexes

# Set index file
DirectoryIndex index.html

# Add MIME types
AddType text/html .html
AddType text/css .css
AddType application/javascript .js
EOF
chmod 644 .htaccess

# Create SQLite database with schema and sample data
echo "3. Initializing SQLite database..."
if [ ! -f parking.db ]; then
    python3 -c "
import sqlite3

# Create database
conn = sqlite3.connect('parking.db')
cursor = conn.cursor()

# Create tables (SQLite compatible)
cursor.executescript('''
CREATE TABLE IF NOT EXISTS buildingInfo(
    buildingId INTEGER PRIMARY KEY,
    buildingName TEXT NOT NULL,
    parkingSpace INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS departmentInfo(
    departmentId INTEGER PRIMARY KEY,
    departmentName TEXT NOT NULL,
    buildingId INTEGER NOT NULL,
    FOREIGN KEY (buildingId) REFERENCES buildingInfo(buildingId)
);

CREATE TABLE IF NOT EXISTS employeeInfo(
    employeeId INTEGER PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    employeeStatus TEXT NOT NULL,
    departmentId INTEGER NOT NULL,
    age INTEGER NOT NULL,
    FOREIGN KEY (departmentId) REFERENCES departmentInfo(departmentId)
);

CREATE TABLE IF NOT EXISTS loginInfo(
    userName TEXT PRIMARY KEY,
    employeeId INTEGER NOT NULL,
    passWord TEXT NOT NULL,
    bookingAuth INTEGER NOT NULL,
    adminAuth INTEGER NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
);

CREATE TABLE IF NOT EXISTS parkingInfo(
    parkingNum INTEGER PRIMARY KEY,
    employeeId INTEGER,
    evCharge INTEGER NOT NULL,
    tempAssign INTEGER NOT NULL,
    fastCharge INTEGER NOT NULL,
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
);

CREATE TABLE IF NOT EXISTS evBook(
    bookId INTEGER PRIMARY KEY,
    parkingNum INTEGER NOT NULL,
    employeeId INTEGER NOT NULL,
    bookingDate TEXT NOT NULL,
    startTime TEXT NOT NULL,
    FOREIGN KEY (parkingNum) REFERENCES parkingInfo(parkingNum),
    FOREIGN KEY (employeeId) REFERENCES employeeInfo(employeeId)
);

CREATE TABLE IF NOT EXISTS parkingWaitList(
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
INSERT OR IGNORE INTO buildingInfo VALUES(1, 'Executive Office', 25);
INSERT OR IGNORE INTO buildingInfo VALUES(2, 'Administration Office', 60);
INSERT OR IGNORE INTO buildingInfo VALUES(3, 'Cafeteria Building', 15);
INSERT OR IGNORE INTO buildingInfo VALUES(4, 'IT Office', 35);

-- Department data
INSERT OR IGNORE INTO departmentInfo VALUES(1, 'Executive Department', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(2, 'Chairman Office', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(3, 'Marketing Department', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(4, 'Human Resources', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(5, 'Finance Department', 2);

-- Employee data
INSERT OR IGNORE INTO employeeInfo VALUES(1, 'Sharon', 'Hsu', 'FT', 1, 55);
INSERT OR IGNORE INTO employeeInfo VALUES(2, 'Jimmy', 'Lee', 'FT', 2, 35);
INSERT OR IGNORE INTO employeeInfo VALUES(3, 'Tom', 'Ford', 'FT', 3, 35);
INSERT OR IGNORE INTO employeeInfo VALUES(4, 'Deva', 'Reeb', 'FT', 3, 45);
INSERT OR IGNORE INTO employeeInfo VALUES(5, 'Joe', 'Woodward', 'FT', 4, 37);

-- Parking spots
INSERT OR IGNORE INTO parkingInfo VALUES(1, NULL, 1, 1, 1);
INSERT OR IGNORE INTO parkingInfo VALUES(2, NULL, 1, 1, 1);
INSERT OR IGNORE INTO parkingInfo VALUES(3, NULL, 1, 1, 0);
INSERT OR IGNORE INTO parkingInfo VALUES(60, 1, 0, 0, 0);
INSERT OR IGNORE INTO parkingInfo VALUES(61, 2, 0, 0, 0);
''')

conn.commit()
conn.close()
print('Database created successfully!')
"
    chmod 666 parking.db
else
    echo "   Database already exists"
fi

# Verify environment
echo ""
echo "4. Verifying school server environment..."
echo -n "   SQLite3: "
if command -v sqlite3 &> /dev/null; then
    sqlite3 --version | head -n1
else
    echo "NOT FOUND - Please contact IT"
fi

echo -n "   Python3: "
if command -v python3 &> /dev/null; then
    python3 --version
else
    echo "NOT FOUND - Please contact IT"
fi

echo -n "   Apache: "
if [ -d "/etc/apache2" ] || [ -d "/etc/httpd" ]; then
    echo "Available"
else
    echo "Configuration may vary"
fi

# Instructions
echo ""
echo "Setup Complete!"
echo "==============="
echo ""
echo "Available Interface:"
echo "  Static HTML Interface: http://your-domain/~username/parking-dbms/"
echo ""
echo "This provides:"
echo "  - SQL query generator for SQLite database"
echo "  - No server-side execution needed"
echo "  - Works within school server restrictions"
echo ""
echo "School Server Restrictions:"
echo "  ✗ No sudo access"
echo "  ✗ Port 80 only (no custom ports)"
echo "  ✗ No CGI/PHP execution"
echo "  ✓ Static HTML/CSS/JS files work"
echo "  ✓ SQLite3 database created locally"
echo ""
echo "Files created:"
echo "  - parking.db (SQLite database with sample data)"
echo "  - .htaccess (Apache configuration)"
echo ""
echo "To use the SQL queries:"
echo "  1. Open the web interface"
echo "  2. Generate SQL commands"
echo "  3. Run them using: sqlite3 parking.db"
echo ""