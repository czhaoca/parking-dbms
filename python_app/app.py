#!/usr/bin/env python3
"""
Parking Management System - Python Flask Version
For deployment on servers without PHP support
"""

from flask import Flask, render_template, request, jsonify, session
import sqlite3
import os
from datetime import datetime
import hashlib

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here-change-in-production')

# Database path
DB_PATH = os.path.join(os.path.dirname(__file__), 'parking.db')

def get_db():
    """Get database connection"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initialize database with schema"""
    conn = get_db()
    with open('schema.sql', 'r') as f:
        conn.executescript(f.read())
    conn.close()

@app.route('/')
def index():
    """Main page"""
    return render_template('index.html')

@app.route('/employees')
def display_employees():
    """Display all employees"""
    conn = get_db()
    cursor = conn.cursor()
    
    employees = cursor.execute('''
        SELECT e.*, d.departmentName, b.buildingName, p.parkingNum
        FROM employeeInfo e
        JOIN departmentInfo d ON e.departmentId = d.departmentId
        JOIN buildingInfo b ON d.buildingId = b.buildingId
        LEFT JOIN parkingInfo p ON e.employeeId = p.employeeId
        ORDER BY e.lastName, e.firstName
    ''').fetchall()
    
    conn.close()
    return render_template('employees.html', employees=employees)

@app.route('/waitlist')
def display_waitlist():
    """Display parking waitlist"""
    conn = get_db()
    cursor = conn.cursor()
    
    waitlist = cursor.execute('''
        SELECT w.*, e.firstName, e.lastName, e.employeeStatus, d.departmentName
        FROM parkingWaitList w
        JOIN employeeInfo e ON w.employeeId = e.employeeId
        JOIN departmentInfo d ON e.departmentId = d.departmentId
        ORDER BY w.waitFrom
    ''').fetchall()
    
    conn.close()
    return render_template('waitlist.html', waitlist=waitlist)

@app.route('/employee-status-report')
def employee_status_report():
    """Generate FT/PT employee report"""
    status = request.args.get('status', 'FT')
    
    conn = get_db()
    cursor = conn.cursor()
    
    employees = cursor.execute('''
        SELECT e.*, d.departmentName, b.buildingName
        FROM employeeInfo e
        JOIN departmentInfo d ON e.departmentId = d.departmentId
        JOIN buildingInfo b ON d.buildingId = b.buildingId
        WHERE e.employeeStatus = ?
        ORDER BY d.departmentName, e.lastName
    ''', (status,)).fetchall()
    
    conn.close()
    return render_template('status_report.html', employees=employees, status=status)

@app.route('/youngest-employee')
def youngest_employee():
    """Find youngest employee"""
    conn = get_db()
    cursor = conn.cursor()
    
    employee = cursor.execute('''
        SELECT e.*, d.departmentName, b.buildingName
        FROM employeeInfo e
        JOIN departmentInfo d ON e.departmentId = d.departmentId
        JOIN buildingInfo b ON d.buildingId = b.buildingId
        ORDER BY e.age
        LIMIT 1
    ''').fetchone()
    
    conn.close()
    return render_template('youngest.html', employee=employee)

@app.route('/api/buildings')
def api_buildings():
    """API endpoint for building data"""
    conn = get_db()
    cursor = conn.cursor()
    
    buildings = cursor.execute('''
        SELECT b.*, 
               COUNT(DISTINCT d.departmentId) as department_count,
               COUNT(DISTINCT p.parkingNum) as occupied_spots
        FROM buildingInfo b
        LEFT JOIN departmentInfo d ON b.buildingId = d.buildingId
        LEFT JOIN parkingInfo p ON p.employeeId IS NOT NULL
        GROUP BY b.buildingId
    ''').fetchall()
    
    conn.close()
    return jsonify([dict(row) for row in buildings])

@app.route('/api/parking-availability')
def api_parking_availability():
    """API endpoint for parking availability"""
    conn = get_db()
    cursor = conn.cursor()
    
    # This is simplified - in real Oracle version, you'd join with actual parking spots
    availability = cursor.execute('''
        SELECT 
            b.buildingName,
            b.parkingSpace as total_spaces,
            COUNT(p.parkingNum) as occupied_spaces,
            b.parkingSpace - COUNT(p.parkingNum) as available_spaces
        FROM buildingInfo b
        LEFT JOIN parkingInfo p ON p.employeeId IS NOT NULL
        GROUP BY b.buildingId
    ''').fetchall()
    
    conn.close()
    return jsonify([dict(row) for row in availability])

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'database': os.path.exists(DB_PATH),
        'time': datetime.now().isoformat()
    })

# Admin routes would go here...

if __name__ == '__main__':
    # Initialize database if it doesn't exist
    if not os.path.exists(DB_PATH):
        init_db()
    
    # Run the application
    app.run(debug=True, host='0.0.0.0', port=5000)