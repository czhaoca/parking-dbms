#!/bin/bash
# Setup script for Python-based Parking Management System
# After PHP/Oracle services terminated, migrated to Python/SQLite

echo "=== Parking Management System - Python Migration Setup ==="
echo "Original PHP/Oracle implementation archived due to service termination"
echo ""

# Check current environment
echo "Checking environment..."
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
echo "Python version: $PYTHON_VERSION"
echo "SQLite3 available: $(which sqlite3 || echo 'Not found')"
echo ""

# Create .htaccess for CGI execution
create_htaccess() {
    cat > .htaccess << 'EOF'
# Enable CGI execution for Python scripts
Options +ExecCGI
AddHandler cgi-script .py

# Directory index
DirectoryIndex index.html index.py

# Disable PHP (no longer available)
RemoveHandler .php

# Protect sensitive files
<FilesMatch "\.(db|sql|log)$">
    Order allow,deny
    Deny from all
</FilesMatch>
EOF
    echo "✓ Created .htaccess for CGI execution"
}

# Check if ports are accessible (for Flask option)
check_port_access() {
    echo "Checking port accessibility..."
    
    # Try to bind to a high port
    timeout 2 python3 -c "
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    s.bind(('0.0.0.0', 8080))
    s.close()
    print('✓ Can bind to port 8080')
    exit(0)
except:
    print('✗ Cannot bind to ports - will use CGI instead')
    exit(1)
" 2>/dev/null
    
    return $?
}

# Setup CGI scripts
setup_cgi() {
    echo ""
    echo "Setting up CGI scripts..."
    
    # Make scripts executable
    chmod +x cgi-bin/*.py
    
    # Create CGI directory in public_html if exists
    if [ -d ~/public_html ]; then
        mkdir -p ~/public_html/parking-dbms/cgi-bin
        cp -r cgi-bin/* ~/public_html/parking-dbms/cgi-bin/
        chmod -R 755 ~/public_html/parking-dbms/cgi-bin/
        
        # Copy .htaccess
        cp .htaccess ~/public_html/parking-dbms/
        
        echo "✓ CGI scripts deployed to ~/public_html/parking-dbms/cgi-bin/"
        echo "  Access: https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/index.py"
    else
        echo "✗ No public_html directory - CGI deployment not possible"
    fi
}

# Setup SQLite database
setup_database() {
    echo ""
    echo "Setting up SQLite database..."
    
    cd python_app
    
    # Create database if doesn't exist
    if [ ! -f parking.db ]; then
        sqlite3 parking.db < schema.sql
        echo "✓ Created SQLite database with schema and sample data"
    else
        echo "✓ Database already exists"
    fi
    
    # Copy database for CGI access
    cp parking.db ../cgi-bin/ 2>/dev/null || true
    
    cd ..
}

# Main setup flow
echo "=== Starting Setup ==="

# 1. Create .htaccess
create_htaccess

# 2. Setup database
setup_database

# 3. Check port access
if check_port_access; then
    echo ""
    echo "Port access available - Flask app can run standalone"
    echo "To run: cd python_app && python3 app.py"
else
    echo ""
    echo "No port access - using CGI deployment only"
fi

# 4. Setup CGI
setup_cgi

# 5. Copy static files
if [ -d ~/public_html ]; then
    cp index.html ~/public_html/parking-dbms/
    cp -r archive ~/public_html/parking-dbms/
    echo "✓ Copied static files to public_html"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Deployment Summary:"
echo "- Original PHP/Oracle code: archived in archive/php-original/"
echo "- Python/SQLite implementation: Ready for deployment"
echo "- Access methods:"
echo "  1. Static documentation: https://www.students.cs.ubc.ca/~$USER/parking-dbms/"
echo "  2. CGI application: https://www.students.cs.ubc.ca/~$USER/parking-dbms/cgi-bin/index.py"
echo ""
echo "Note: This project migrated from PHP/Oracle after course infrastructure was terminated."