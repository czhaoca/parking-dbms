#!/usr/bin/env python3
"""
Parking Database Management System
SQLite + Python Web Application
"""

import sqlite3
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import os
import sys

# Configuration
PORT = 80
DB_FILE = "parking.db"
STATIC_DIR = "/work/parking-dbms"

class ParkingDBHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urlparse(self.path)
        
        # Serve static files
        if parsed_path.path == '/':
            self.serve_file('/index.html')
        elif parsed_path.path.endswith(('.html', '.css', '.js')):
            self.serve_file(parsed_path.path)
        elif parsed_path.path == '/api/status':
            self.handle_api_status()
        elif parsed_path.path == '/api/employees':
            self.handle_api_employees()
        elif parsed_path.path == '/api/parking':
            self.handle_api_parking()
        elif parsed_path.path == '/api/reports':
            self.handle_api_reports()
        else:
            self.send_error(404)
    
    def do_POST(self):
        """Handle POST requests"""
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/employee/add':
            self.handle_add_employee()
        elif parsed_path.path == '/api/parking/assign':
            self.handle_assign_parking()
        else:
            self.send_error(404)
    
    def serve_file(self, path):
        """Serve static files"""
        if path.startswith('/'):
            path = path[1:]
        
        filepath = os.path.join(STATIC_DIR, path)
        
        if not os.path.exists(filepath) or not os.path.isfile(filepath):
            self.send_error(404)
            return
        
        # Determine content type
        content_types = {
            '.html': 'text/html',
            '.css': 'text/css',
            '.js': 'application/javascript'
        }
        
        ext = os.path.splitext(filepath)[1]
        content_type = content_types.get(ext, 'text/plain')
        
        # Send response
        with open(filepath, 'rb') as f:
            content = f.read()
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', len(content))
            self.end_headers()
            self.wfile.write(content)
    
    def handle_api_status(self):
        """Get database status"""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get counts from each table
        status = {}
        tables = ['employeeInfo', 'buildingInfo', 'departmentInfo', 'parkingInfo', 'parkingWaitList', 'evBook']
        
        for table in tables:
            cursor.execute(f'SELECT COUNT(*) FROM {table}')
            status[table] = cursor.fetchone()[0]
        
        conn.close()
        
        self.send_json_response(status)
    
    def handle_api_employees(self):
        """Get employee list"""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT e.employeeId, e.firstName, e.lastName, e.employeeStatus, 
                   e.age, d.departmentName
            FROM employeeInfo e
            JOIN departmentInfo d ON e.departmentId = d.departmentId
            ORDER BY e.employeeId
        ''')
        
        employees = []
        for row in cursor.fetchall():
            employees.append({
                'employeeId': row[0],
                'firstName': row[1],
                'lastName': row[2],
                'status': row[3],
                'age': row[4],
                'department': row[5]
            })
        
        conn.close()
        self.send_json_response(employees)
    
    def handle_api_parking(self):
        """Get parking status"""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT p.parkingNum, p.evCharge, p.fastCharge,
                   e.employeeId, e.firstName, e.lastName
            FROM parkingInfo p
            LEFT JOIN employeeInfo e ON p.employeeId = e.employeeId
            ORDER BY p.parkingNum
        ''')
        
        parking = []
        for row in cursor.fetchall():
            parking.append({
                'parkingNum': row[0],
                'evCharge': row[1],
                'fastCharge': row[2],
                'employeeId': row[3],
                'employeeName': f"{row[4]} {row[5]}" if row[3] else None
            })
        
        conn.close()
        self.send_json_response(parking)
    
    def handle_api_reports(self):
        """Get report data"""
        conn = get_db_connection()
        cursor = conn.cursor()
        
        reports = {}
        
        # Employee status report
        cursor.execute('''
            SELECT employeeStatus, COUNT(*) as count
            FROM employeeInfo
            GROUP BY employeeStatus
        ''')
        reports['employeeStatus'] = cursor.fetchall()
        
        # Parking utilization
        cursor.execute('''
            SELECT 
                COUNT(*) as total,
                COUNT(employeeId) as occupied,
                COUNT(*) - COUNT(employeeId) as available
            FROM parkingInfo
        ''')
        reports['parkingUtilization'] = cursor.fetchone()
        
        # Waitlist
        cursor.execute('''
            SELECT COUNT(*) FROM parkingWaitList WHERE parkingNum IS NULL
        ''')
        reports['waitlistCount'] = cursor.fetchone()[0]
        
        conn.close()
        self.send_json_response(reports)
    
    def handle_add_employee(self):
        """Add new employee"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO employeeInfo (employeeId, firstName, lastName, 
                                        employeeStatus, departmentId, age)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (data['employeeId'], data['firstName'], data['lastName'],
                  data['status'], data['departmentId'], data['age']))
            
            conn.commit()
            self.send_json_response({'success': True, 'message': 'Employee added successfully'})
        except Exception as e:
            conn.rollback()
            self.send_json_response({'success': False, 'message': str(e)}, 400)
        finally:
            conn.close()
    
    def handle_assign_parking(self):
        """Assign parking spot"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        data = json.loads(post_data.decode('utf-8'))
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                UPDATE parkingInfo 
                SET employeeId = ? 
                WHERE parkingNum = ? AND employeeId IS NULL
            ''', (data['employeeId'], data['parkingNum']))
            
            if cursor.rowcount == 0:
                raise Exception('Parking spot not available')
            
            conn.commit()
            self.send_json_response({'success': True, 'message': 'Parking assigned successfully'})
        except Exception as e:
            conn.rollback()
            self.send_json_response({'success': False, 'message': str(e)}, 400)
        finally:
            conn.close()
    
    def send_json_response(self, data, status=200):
        """Send JSON response"""
        content = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(content))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(content)

def get_db_connection():
    """Get SQLite database connection"""
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def init_database():
    """Initialize SQLite database from SQL file"""
    print("Initializing database...")
    
    # Read and convert Oracle SQL to SQLite
    sql_file = os.path.join(STATIC_DIR, 'src', 'parkingdata.sql')
    
    if not os.path.exists(sql_file):
        print(f"Error: {sql_file} not found!")
        return False
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    # Create tables (SQLite compatible version)
    create_sql = '''
    -- Drop tables if exist
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
    '''
    
    cursor.executescript(create_sql)
    
    # Read the original SQL file and extract INSERT statements
    with open(sql_file, 'r') as f:
        sql_content = f.read()
    
    # Extract and execute INSERT statements
    for line in sql_content.split('\n'):
        if line.strip().lower().startswith('insert into'):
            # Skip the line if it's a comment
            if '--' not in line or line.strip().index('insert') < line.strip().index('--'):
                try:
                    cursor.execute(line.strip())
                except Exception as e:
                    print(f"Warning: Could not execute: {line[:50]}... Error: {e}")
    
    conn.commit()
    conn.close()
    
    print("Database initialized successfully!")
    return True

def main():
    """Main server function"""
    # Initialize database if it doesn't exist
    if not os.path.exists(DB_FILE):
        if not init_database():
            sys.exit(1)
    
    # Change to static directory
    os.chdir(STATIC_DIR)
    
    # Start server
    try:
        server = HTTPServer(('', PORT), ParkingDBHandler)
        print(f"Parking Database Management System (SQLite)")
        print(f"Server running at http://localhost:{PORT}/")
        print(f"Database: {DB_FILE}")
        print("Press Ctrl+C to stop the server")
        server.serve_forever()
    except PermissionError:
        print(f"Error: Permission denied to bind to port {PORT}")
        print("Try running with sudo: sudo python3 app.py")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nServer stopped.")
        sys.exit(0)

if __name__ == "__main__":
    main()