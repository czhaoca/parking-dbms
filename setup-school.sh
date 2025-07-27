#!/bin/bash
# Setup script for school Apache server (no sudo required)

echo "Parking Database Management System - School Server Setup"
echo "======================================================="
echo ""

# Check current directory
CURRENT_DIR=$(pwd)
echo "Setting up in: $CURRENT_DIR"
echo ""

# Make Python scripts executable
echo "1. Making Python scripts executable..."
chmod +x cgi-bin/*.py 2>/dev/null || echo "   Note: cgi-bin scripts will be created"
chmod +x *.py 2>/dev/null || echo "   Note: No Python scripts in root yet"

# Set proper permissions for Apache
echo "2. Setting directory permissions..."
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

# Make scripts executable
chmod 755 cgi-bin/*.py 2>/dev/null
chmod 755 *.sh 2>/dev/null

# Special permissions for .htaccess
chmod 644 .htaccess

# Create parking.db with proper permissions
echo "3. Initializing SQLite database..."
if [ ! -f parking.db ]; then
    python3 -c "
import sqlite3
conn = sqlite3.connect('parking.db')
cursor = conn.cursor()

# Create tables
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
INSERT OR IGNORE INTO buildingInfo VALUES(1, 'Executive Office', 25);
INSERT OR IGNORE INTO buildingInfo VALUES(2, 'Administration Office', 60);
INSERT OR IGNORE INTO buildingInfo VALUES(3, 'Cafeteria Building', 15);
INSERT OR IGNORE INTO buildingInfo VALUES(4, 'IT Office', 35);

INSERT OR IGNORE INTO departmentInfo VALUES(1, 'Executive Department', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(2, 'Chairman Office', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(3, 'Marketing Department', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(4, 'Human Resources', 1);
INSERT OR IGNORE INTO departmentInfo VALUES(5, 'Finance Department', 2);

INSERT OR IGNORE INTO employeeInfo VALUES(1, 'Sharon', 'Hsu', 'FT', 1, 55);
INSERT OR IGNORE INTO employeeInfo VALUES(2, 'Jimmy', 'Lee', 'FT', 2, 35);
INSERT OR IGNORE INTO employeeInfo VALUES(3, 'Tom', 'Ford', 'FT', 3, 35);
INSERT OR IGNORE INTO employeeInfo VALUES(4, 'Deva', 'Reeb', 'FT', 3, 45);
INSERT OR IGNORE INTO employeeInfo VALUES(5, 'Joe', 'Woodward', 'FT', 4, 37);

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

# Test Python availability
echo ""
echo "4. Checking Python installation..."
if command -v python3 &> /dev/null; then
    echo "   Python 3 found: $(python3 --version)"
else
    echo "   ERROR: Python 3 not found!"
    exit 1
fi

# Create a simple test CGI script
echo ""
echo "5. Creating test CGI script..."
mkdir -p cgi-bin
cat > cgi-bin/test.py << 'EOF'
#!/usr/bin/env python3
print("Content-Type: text/html\n")
print("<h1>CGI is working!</h1>")
print("<p>Python CGI scripts are executing correctly.</p>")
EOF
chmod 755 cgi-bin/test.py

# Provide instructions
echo ""
echo "Setup Complete!"
echo "==============="
echo ""
echo "Access your application at:"
echo "  Main page: http://your-domain/parking-dbms/"
echo "  CGI test: http://your-domain/parking-dbms/cgi-bin/test.py"
echo "  Database app: http://your-domain/parking-dbms/cgi-bin/index.py"
echo ""
echo "Available interfaces:"
echo "  1. Static SQL Generator: index.html (no server-side needed)"
echo "  2. Python CGI App: cgi-bin/index.py (full database access)"
echo ""
echo "If CGI doesn't work, you may need to:"
echo "  1. Contact IT to enable CGI for your account"
echo "  2. Check if .htaccess overrides are allowed"
echo "  3. Use the static HTML interface instead"
echo ""
echo "Files created:"
echo "  - parking.db (SQLite database)"
echo "  - cgi-bin/test.py (CGI test script)"
echo "  - .htaccess (Apache configuration)"
echo ""