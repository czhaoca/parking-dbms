#!/usr/bin/env python3
"""
Parking Management System - Modern CGI Version
Works without deprecated cgi/cgitb modules
"""

import sys
import os
import sqlite3
import json
from urllib.parse import parse_qs

# Print HTTP header first
print("Content-Type: text/html; charset=utf-8")
print()

try:
    # Get database path
    DB_PATH = os.path.join(os.path.dirname(__file__), 'parking.db')
    
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(f"Database not found at {DB_PATH}")
    
    # Connect to database
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Get some data
    employees = cursor.execute('''
        SELECT e.*, d.departmentName, b.buildingName, p.parkingNum
        FROM employeeInfo e
        JOIN departmentInfo d ON e.departmentId = d.departmentId
        JOIN buildingInfo b ON d.buildingId = b.buildingId
        LEFT JOIN parkingInfo p ON e.employeeId = p.employeeId
        ORDER BY e.lastName, e.firstName
        LIMIT 10
    ''').fetchall()
    
    # Output HTML
    print("""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parking Management System</title>
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
        .notice {
            background: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
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
        .nav {
            margin: 20px 0;
        }
        .nav a {
            display: inline-block;
            padding: 10px 20px;
            margin: 5px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .nav a:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Parking Management System</h1>
        
        <div class="notice">
            <strong>Migration Notice:</strong> This system was migrated from PHP/Oracle to Python/SQLite 
            after the university terminated database services upon course completion.
        </div>
        
        <div class="nav">
            <a href="modern_index.py">Home</a>
            <a href="../index.html">Documentation</a>
            <a href="../archive/php-original/">Original PHP Code</a>
        </div>
        
        <h2>Employee List (First 10)</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Status</th>
                <th>Department</th>
                <th>Building</th>
                <th>Parking Spot</th>
            </tr>""")
    
    # Display employees
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
            </tr>""")
    
    print("""
        </table>
        
        <p style="margin-top: 30px; color: #666;">
            Python {}.{} | SQLite {} | Working Directory: {}
        </p>
    </div>
</body>
</html>""".format(sys.version_info.major, sys.version_info.minor, sqlite3.sqlite_version, os.getcwd()))
    
    conn.close()
    
except Exception as e:
    # Error handling
    print(f"""
    <html>
    <body>
        <h1>Error</h1>
        <p style="color: red;">{str(e)}</p>
        <pre>{type(e).__name__}: {str(e)}</pre>
        <p>Python Version: {sys.version}</p>
        <p>Working Directory: {os.getcwd()}</p>
    </body>
    </html>
    """)