#!/bin/bash
# Debug CGI execution issues

echo "=== Debugging CGI Internal Server Error ==="
echo ""

# 1. Check Python shebang line
echo "1. Checking Python path in CGI scripts..."
head -n 1 ~/public_html/parking-dbms/cgi-bin/index.py
echo "   Actual Python location: $(which python3)"
echo ""

# 2. Test Python script directly
echo "2. Testing Python script directly..."
cd ~/public_html/parking-dbms/cgi-bin/
python3 index.py > test_output.html 2> test_error.log
if [ -s test_error.log ]; then
    echo "   ✗ Python errors found:"
    cat test_error.log
else
    echo "   ✓ Python script runs without errors"
fi
echo ""

# 3. Check file format (DOS/Unix line endings)
echo "3. Checking file format..."
if file index.py | grep -q "CRLF"; then
    echo "   ✗ DOS line endings detected - converting to Unix format"
    dos2unix index.py 2>/dev/null || sed -i 's/\r$//' index.py
else
    echo "   ✓ Unix line endings (correct)"
fi
echo ""

# 4. Check database file
echo "4. Checking database access..."
if [ -f parking.db ]; then
    echo "   ✓ Database exists"
    echo "   Database size: $(ls -lh parking.db | awk '{print $5}')"
    echo "   Database permissions: $(ls -l parking.db | awk '{print $1}')"
    # Make sure it's readable
    chmod 644 parking.db
else
    echo "   ✗ Database not found!"
fi
echo ""

# 5. Create a minimal test CGI
echo "5. Creating minimal test CGI..."
cat > test.py << 'EOF'
#!/usr/bin/env python3
print("Content-Type: text/html")
print()
print("<h1>CGI Works!</h1>")
print("<p>Python version: {}</p>".format(sys.version))
import sys
EOF
chmod 755 test.py
echo "   Created test.py - try: https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/test.py"
echo ""

# 6. Fix the main CGI script
echo "6. Fixing main CGI script..."
# Update shebang to use env
sed -i '1s|.*|#!/usr/bin/env python3|' index.py

# Make sure it's executable
chmod 755 index.py

# Add error handling to the beginning
cat > index_fixed.py << 'EOF'
#!/usr/bin/env python3
"""
Parking Management System - CGI Version
Simple CGI script that can run on Apache without mod_wsgi
"""

import sys
import os

# Enable detailed error reporting
import cgitb
cgitb.enable(display=1, logdir="/tmp")

try:
    import cgi
    import sqlite3
    
    # Print HTTP header first
    print("Content-Type: text/html; charset=utf-8")
    print()
    
    # Test basic output
    print("<!DOCTYPE html><html><body>")
    print("<h1>Parking Management System - Debug Mode</h1>")
    print(f"<p>Python Version: {sys.version}</p>")
    print(f"<p>Working Directory: {os.getcwd()}</p>")
    print(f"<p>Script Name: {os.path.basename(__file__)}</p>")
    
    # Check database
    db_path = os.path.join(os.path.dirname(__file__), 'parking.db')
    if os.path.exists(db_path):
        print(f"<p style='color:green'>✓ Database found at: {db_path}</p>")
    else:
        print(f"<p style='color:red'>✗ Database NOT found at: {db_path}</p>")
    
    print("</body></html>")
    
except Exception as e:
    print("Content-Type: text/html")
    print()
    print(f"<h1>Error</h1><pre>{str(e)}</pre>")
    import traceback
    print(f"<pre>{traceback.format_exc()}</pre>")
EOF

chmod 755 index_fixed.py
echo "   Created index_fixed.py with better error handling"
echo "   Try: https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/index_fixed.py"
echo ""

# 7. Check Apache error log if accessible
echo "7. Recent errors (if accessible):"
tail -n 20 /var/log/apache2/error.log 2>/dev/null || echo "   Cannot access Apache error log"
echo ""

echo "=== Debugging Complete ==="
echo ""
echo "Try these URLs in order:"
echo "1. https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/test.py"
echo "2. https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/index_fixed.py"
echo "3. Original: https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/index.py"
echo ""
echo "If test.py works but index.py doesn't, the issue is in the script."
echo "If neither works, CGI execution might be disabled for your account."