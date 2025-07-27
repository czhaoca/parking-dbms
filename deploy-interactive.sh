#!/bin/bash
# Deploy Interactive Parking Database System on School Server

echo "Deploying Interactive Parking Database System"
echo "============================================"
echo ""

# Ensure we're in the right directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if database exists, create if not
if [ ! -f "parking.db" ]; then
    echo "Creating database..."
    python3 app.py << EOF
y
EOF
fi

# Set permissions
echo "Setting permissions..."
chmod 755 .
chmod 755 cgi-bin
chmod 755 cgi-bin/*.py
chmod 644 *.html
chmod 644 .htaccess
chmod 666 parking.db

# Create test data if database is empty
echo "Checking database content..."
EMPLOYEE_COUNT=$(sqlite3 parking.db "SELECT COUNT(*) FROM employeeInfo;" 2>/dev/null || echo "0")

if [ "$EMPLOYEE_COUNT" -eq "0" ]; then
    echo "Database is empty. Run app.py to populate with sample data."
fi

# Test CGI
echo ""
echo "Testing CGI functionality..."
python3 cgi-bin/parking-api.py > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ CGI script syntax is valid"
else
    echo "✗ CGI script has syntax errors"
fi

# Display access URLs
echo ""
echo "Deployment Complete!"
echo "===================="
echo ""
echo "Access your application at:"
echo "  Interactive Interface: http://students.cs.ubc.ca/~czha/parking-dbms/interactive.html"
echo "  Static SQL Generator: http://students.cs.ubc.ca/~czha/parking-dbms/"
echo "  API Endpoint: http://students.cs.ubc.ca/~czha/parking-dbms/cgi-bin/parking-api.py"
echo ""
echo "Features available:"
echo "  ✓ Full CRUD operations for employees"
echo "  ✓ Parking spot assignment/release"
echo "  ✓ Waitlist management"
echo "  ✓ Real-time statistics dashboard"
echo "  ✓ Search and filtering"
echo "  ✓ Reports and analytics"
echo ""
echo "Troubleshooting:"
echo "  - If CGI doesn't work, check Apache error logs"
echo "  - Ensure all files have correct permissions"
echo "  - Check that Python 3 path is correct in CGI scripts"
echo ""