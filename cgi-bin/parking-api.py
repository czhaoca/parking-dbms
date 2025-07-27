#!/usr/bin/env python3
"""
Parking Database Management System - CGI API
Provides CRUD operations via CGI interface
"""

import cgi
import cgitb
import json
import sqlite3
import os
import sys
from pathlib import Path

# Enable CGI error reporting
cgitb.enable()

# Database path (one level up from cgi-bin)
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'parking.db')

def send_json_response(data, status="200 OK"):
    """Send JSON response with proper headers"""
    print(f"Status: {status}")
    print("Content-Type: application/json")
    print("Access-Control-Allow-Origin: *")
    print("Access-Control-Allow-Methods: GET, POST, PUT, DELETE")
    print("Access-Control-Allow-Headers: Content-Type")
    print()
    print(json.dumps(data))

def get_db_connection():
    """Create database connection"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except Exception as e:
        send_json_response({"error": f"Database connection failed: {str(e)}"}, "500 Internal Server Error")
        sys.exit(1)

def handle_get(params):
    """Handle GET requests"""
    table = params.get('table', [''])[0]
    id_param = params.get('id', [''])[0]
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if table == 'employees':
            if id_param:
                cursor.execute('''
                    SELECT e.*, d.departmentName, d.buildingId 
                    FROM employeeInfo e
                    LEFT JOIN departmentInfo d ON e.departmentId = d.departmentId
                    WHERE e.employeeId = ?
                ''', (id_param,))
                row = cursor.fetchone()
                if row:
                    result = dict(row)
                else:
                    result = None
            else:
                cursor.execute('''
                    SELECT e.*, d.departmentName, d.buildingId 
                    FROM employeeInfo e
                    LEFT JOIN departmentInfo d ON e.departmentId = d.departmentId
                    ORDER BY e.employeeId
                ''')
                result = [dict(row) for row in cursor.fetchall()]
                
        elif table == 'parking':
            if id_param:
                cursor.execute('''
                    SELECT p.*, e.firstName, e.lastName 
                    FROM parkingInfo p
                    LEFT JOIN employeeInfo e ON p.employeeId = e.employeeId
                    WHERE p.parkingNum = ?
                ''', (id_param,))
                row = cursor.fetchone()
                result = dict(row) if row else None
            else:
                cursor.execute('''
                    SELECT p.*, e.firstName, e.lastName 
                    FROM parkingInfo p
                    LEFT JOIN employeeInfo e ON p.employeeId = e.employeeId
                    ORDER BY p.parkingNum
                ''')
                result = [dict(row) for row in cursor.fetchall()]
                
        elif table == 'departments':
            cursor.execute('''
                SELECT d.*, b.buildingName 
                FROM departmentInfo d
                JOIN buildingInfo b ON d.buildingId = b.buildingId
                ORDER BY d.departmentId
            ''')
            result = [dict(row) for row in cursor.fetchall()]
            
        elif table == 'buildings':
            cursor.execute('SELECT * FROM buildingInfo ORDER BY buildingId')
            result = [dict(row) for row in cursor.fetchall()]
            
        elif table == 'waitlist':
            cursor.execute('''
                SELECT w.*, e.firstName, e.lastName 
                FROM parkingWaitList w
                JOIN employeeInfo e ON w.employeeId = e.employeeId
                WHERE w.parkingNum IS NULL
                ORDER BY w.waitFrom
            ''')
            result = [dict(row) for row in cursor.fetchall()]
            
        elif table == 'stats':
            # Get various statistics
            stats = {}
            
            # Employee stats
            cursor.execute('SELECT employeeStatus, COUNT(*) as count FROM employeeInfo GROUP BY employeeStatus')
            stats['employeesByStatus'] = dict(cursor.fetchall())
            
            # Parking stats
            cursor.execute('SELECT COUNT(*) as total FROM parkingInfo')
            stats['totalParkingSpots'] = cursor.fetchone()['total']
            
            cursor.execute('SELECT COUNT(*) as occupied FROM parkingInfo WHERE employeeId IS NOT NULL')
            stats['occupiedSpots'] = cursor.fetchone()['occupied']
            
            # Waitlist count
            cursor.execute('SELECT COUNT(*) as waiting FROM parkingWaitList WHERE parkingNum IS NULL')
            stats['waitlistCount'] = cursor.fetchone()['waiting']
            
            result = stats
        else:
            result = {"error": "Invalid table parameter"}
            
        send_json_response({"success": True, "data": result})
        
    except Exception as e:
        send_json_response({"success": False, "error": str(e)}, "500 Internal Server Error")
    finally:
        conn.close()

def handle_post(params, post_data):
    """Handle POST requests (Create)"""
    table = params.get('table', [''])[0]
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if table == 'employees':
            cursor.execute('''
                INSERT INTO employeeInfo (employeeId, firstName, lastName, employeeStatus, departmentId, age)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (post_data['employeeId'], post_data['firstName'], post_data['lastName'],
                  post_data['employeeStatus'], post_data['departmentId'], post_data['age']))
                  
        elif table == 'parking':
            cursor.execute('''
                INSERT INTO parkingInfo (parkingNum, employeeId, evCharge, tempAssign, fastCharge)
                VALUES (?, ?, ?, ?, ?)
            ''', (post_data['parkingNum'], post_data.get('employeeId'), 
                  post_data.get('evCharge', 0), post_data.get('tempAssign', 0), 
                  post_data.get('fastCharge', 0)))
                  
        elif table == 'waitlist':
            cursor.execute('''
                INSERT INTO parkingWaitList (waitListId, employeeId, waitFrom, parkingNum)
                VALUES (?, ?, date('now'), NULL)
            ''', (post_data['waitListId'], post_data['employeeId']))
            
        else:
            send_json_response({"success": False, "error": "Invalid table"}, "400 Bad Request")
            return
            
        conn.commit()
        send_json_response({"success": True, "message": f"Record created in {table}"})
        
    except Exception as e:
        conn.rollback()
        send_json_response({"success": False, "error": str(e)}, "500 Internal Server Error")
    finally:
        conn.close()

def handle_put(params, put_data):
    """Handle PUT requests (Update)"""
    table = params.get('table', [''])[0]
    id_param = params.get('id', [''])[0]
    
    if not id_param:
        send_json_response({"success": False, "error": "ID parameter required"}, "400 Bad Request")
        return
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if table == 'employees':
            cursor.execute('''
                UPDATE employeeInfo 
                SET firstName = ?, lastName = ?, employeeStatus = ?, departmentId = ?, age = ?
                WHERE employeeId = ?
            ''', (put_data['firstName'], put_data['lastName'], put_data['employeeStatus'],
                  put_data['departmentId'], put_data['age'], id_param))
                  
        elif table == 'parking':
            if 'assign' in params:
                # Assign parking spot
                cursor.execute('''
                    UPDATE parkingInfo SET employeeId = ? WHERE parkingNum = ? AND employeeId IS NULL
                ''', (put_data['employeeId'], id_param))
            elif 'release' in params:
                # Release parking spot
                cursor.execute('''
                    UPDATE parkingInfo SET employeeId = NULL WHERE parkingNum = ?
                ''', (id_param,))
            else:
                # General update
                cursor.execute('''
                    UPDATE parkingInfo 
                    SET evCharge = ?, tempAssign = ?, fastCharge = ?
                    WHERE parkingNum = ?
                ''', (put_data['evCharge'], put_data['tempAssign'], 
                      put_data['fastCharge'], id_param))
                      
        else:
            send_json_response({"success": False, "error": "Invalid table"}, "400 Bad Request")
            return
            
        if cursor.rowcount == 0:
            send_json_response({"success": False, "error": "Record not found or no changes made"}, "404 Not Found")
        else:
            conn.commit()
            send_json_response({"success": True, "message": f"Record updated in {table}"})
        
    except Exception as e:
        conn.rollback()
        send_json_response({"success": False, "error": str(e)}, "500 Internal Server Error")
    finally:
        conn.close()

def handle_delete(params):
    """Handle DELETE requests"""
    table = params.get('table', [''])[0]
    id_param = params.get('id', [''])[0]
    
    if not id_param:
        send_json_response({"success": False, "error": "ID parameter required"}, "400 Bad Request")
        return
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if table == 'employees':
            cursor.execute('DELETE FROM employeeInfo WHERE employeeId = ?', (id_param,))
        elif table == 'parking':
            cursor.execute('DELETE FROM parkingInfo WHERE parkingNum = ?', (id_param,))
        elif table == 'waitlist':
            cursor.execute('DELETE FROM parkingWaitList WHERE waitListId = ?', (id_param,))
        else:
            send_json_response({"success": False, "error": "Invalid table"}, "400 Bad Request")
            return
            
        if cursor.rowcount == 0:
            send_json_response({"success": False, "error": "Record not found"}, "404 Not Found")
        else:
            conn.commit()
            send_json_response({"success": True, "message": f"Record deleted from {table}"})
        
    except Exception as e:
        conn.rollback()
        send_json_response({"success": False, "error": str(e)}, "500 Internal Server Error")
    finally:
        conn.close()

def main():
    """Main CGI handler"""
    # Get request method
    method = os.environ.get('REQUEST_METHOD', 'GET')
    
    # Parse query parameters
    form = cgi.FieldStorage()
    params = {}
    for key in form.keys():
        params[key] = form.getlist(key)
    
    # Handle preflight requests
    if method == 'OPTIONS':
        print("Status: 200 OK")
        print("Access-Control-Allow-Origin: *")
        print("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS")
        print("Access-Control-Allow-Headers: Content-Type")
        print()
        return
    
    # Route to appropriate handler
    if method == 'GET':
        handle_get(params)
    elif method == 'POST':
        # Read POST data
        content_length = int(os.environ.get('CONTENT_LENGTH', 0))
        if content_length > 0:
            post_data = json.loads(sys.stdin.read(content_length))
        else:
            post_data = {}
        handle_post(params, post_data)
    elif method == 'PUT':
        # Read PUT data
        content_length = int(os.environ.get('CONTENT_LENGTH', 0))
        if content_length > 0:
            put_data = json.loads(sys.stdin.read(content_length))
        else:
            put_data = {}
        handle_put(params, put_data)
    elif method == 'DELETE':
        handle_delete(params)
    else:
        send_json_response({"error": "Method not allowed"}, "405 Method Not Allowed")

if __name__ == '__main__':
    main()