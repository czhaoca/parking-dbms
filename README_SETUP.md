# Parking Database Management System - Quick Setup

## Overview
This is a simple static HTML/JavaScript application that generates SQL commands for managing a parking database system. Since PHP is not available on the server, this solution provides a web interface to generate the SQL commands that can be executed directly in your Oracle database client.

## How to Use

### 1. Start the Web Server
```bash
# Navigate to the project directory
cd /work/parking-dbms

# Start the server on port 80 (requires sudo)
sudo python3 serve.py

# Or if port 80 is blocked, modify serve.py to use port 8080:
# Change PORT = 80 to PORT = 8080 in serve.py
python3 serve.py
```

### 2. Access the Application
Open your web browser and navigate to:
- http://localhost/ (if using port 80)
- http://localhost:8080/ (if using port 8080)

### 3. Using the Application

#### Overview Tab
- View system information and database connection details
- See the list of all database tables

#### Employee Management Tab
- Generate INSERT SQL for new employees
- View sample SQL for employee operations (SELECT, UPDATE, DELETE)

#### Parking Management Tab
- Generate SQL to assign parking spots to employees
- View SQL for checking available spots and managing allocations

#### Reports Tab
- Contains pre-written SQL queries for common reports:
  - Employee status breakdown (FT/PT)
  - Parking utilization statistics
  - Waitlist management
  - Department-wise parking allocation

#### Database Setup Tab
- Instructions for initial database setup
- Verification queries to ensure proper installation

### 4. Execute SQL Commands
1. Copy the generated SQL from the web interface
2. Connect to your Oracle database using SQL*Plus or SQL Developer:
   ```
   sqlplus ora_[username]/a[student_number]@dbhost.students.cs.ubc.ca:1522/stu
   ```
3. Paste and execute the SQL commands

## Files Structure
- `index.html` - Main application interface
- `serve.py` - Python web server script
- `src/parkingdata.sql` - Complete database schema and sample data
- `db_connect.php` - PHP connection file (for reference, not functional without PHP)
- `employee_management.php` - PHP employee page (for reference)
- `parking_management.php` - PHP parking page (for reference)
- `reports.php` - PHP reports page (for reference)

## Important Notes
1. This is a SQL command generator - it doesn't connect to the database directly
2. You need to manually execute the generated SQL in your Oracle client
3. Always verify the generated SQL before executing
4. Remember to COMMIT your changes in Oracle after INSERT/UPDATE/DELETE operations

## Troubleshooting
- If port 80 is blocked, modify `serve.py` to use a different port (e.g., 8080, 8000)
- Ensure you have Python 3 installed
- For database connection issues, verify your Oracle credentials and VPN connection