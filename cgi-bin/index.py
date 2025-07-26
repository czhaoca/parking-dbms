#!/usr/bin/env python3
"""
Parking Management System - CGI Version
Simple CGI script that can run on Apache without mod_wsgi
"""

import sys
import os

# Enable CGI error reporting with more details
import cgitb
cgitb.enable(display=1, logdir="/tmp")

try:
    import cgi
    import sqlite3
    
    # Print HTTP header FIRST - this is critical
    print("Content-Type: text/html; charset=utf-8")
    print()
    
except Exception as e:
    # If imports fail, still try to output valid HTTP
    print("Content-Type: text/html")
    print()
    print(f"<h1>Import Error</h1><pre>{str(e)}</pre>")
    sys.exit(1)

# Database path - try multiple locations
DB_PATH = None
possible_paths = [
    os.path.join(os.path.dirname(__file__), 'parking.db'),
    os.path.join(os.path.dirname(__file__), '..', 'parking.db'),
    os.path.join(os.path.dirname(__file__), '..', 'python_app', 'parking.db'),
    'parking.db'
]

for path in possible_paths:
    if os.path.exists(path):
        DB_PATH = path
        break

if not DB_PATH:
    print("<h1>Error: Database not found</h1>")
    print("<p>Searched in:</p><ul>")
    for path in possible_paths:
        print(f"<li>{path}</li>")
    print("</ul>")
    sys.exit(1)

def get_employees():
    """Get all employees from database"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        employees = cursor.execute('''
            SELECT e.*, d.departmentName, b.buildingName, p.parkingNum
            FROM employeeInfo e
            JOIN departmentInfo d ON e.departmentId = d.departmentId
            JOIN buildingInfo b ON d.buildingId = b.buildingId
            LEFT JOIN parkingInfo p ON e.employeeId = p.employeeId
            ORDER BY e.lastName, e.firstName
            LIMIT 10
        ''').fetchall()
        
        conn.close()
        return employees
    except Exception as e:
        return str(e)

# HTML output
print("""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parking Management System - Python CGI</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .info {
            background: #e8f4f8;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .menu {
            margin: 20px 0;
        }
        .menu a {
            display: inline-block;
            padding: 10px 20px;
            margin: 5px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .menu a:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Parking Management System</h1>
        <div class="info">
            <strong>Python CGI Version</strong> - Running on Apache without PHP
        </div>
        
        <div class="menu">
            <a href="index.py">Home</a>
            <a href="employees.py">All Employees</a>
            <a href="waitlist.py">Waitlist</a>
            <a href="report.py">Reports</a>
        </div>
        
        <h2>Employee List (First 10)</h2>
""")

# Try to display employees
try:
    employees = get_employees()
    
    if isinstance(employees, str):
        print(f"<p>Error loading employees: {employees}</p>")
    else:
        print("""
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Status</th>
                <th>Department</th>
                <th>Building</th>
                <th>Parking Spot</th>
            </tr>
        """)
        
        for emp in employees:
            parking = emp['parkingNum'] if emp['parkingNum'] else 'None'
            print(f"""
            <tr>
                <td>{emp['employeeId']}</td>
                <td>{emp['firstName']} {emp['lastName']}</td>
                <td>{emp['employeeStatus']}</td>
                <td>{emp['departmentName']}</td>
                <td>{emp['buildingName']}</td>
                <td>{parking}</td>
            </tr>
            """)
        
        print("</table>")
        
except Exception as e:
    print(f"<p>Error: {str(e)}</p>")
    print(f"<p>Python version: {sys.version}</p>")
    print(f"<p>Script location: {os.path.abspath(__file__)}</p>")

print("""
    </div>
</body>
</html>
""")