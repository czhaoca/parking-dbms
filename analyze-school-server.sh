#!/bin/bash
# School Server Environment Analysis Script
# Explores available packages and capabilities for interactive web functionality

echo "School Server Environment Analysis"
echo "=================================="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Home: $HOME"
echo "PWD: $(pwd)"
echo ""

# Create output file
OUTPUT_FILE="school-server-analysis.txt"
echo "Saving analysis to: $OUTPUT_FILE"
echo "" > $OUTPUT_FILE

# Function to log output
log_output() {
    echo "$1"
    echo "$1" >> $OUTPUT_FILE
}

# System Information
log_output "=== SYSTEM INFORMATION ==="
log_output "Hostname: $(hostname)"
log_output "OS: $(uname -a)"
log_output ""

# Check for package managers
log_output "=== PACKAGE MANAGERS ==="
if command -v apt &> /dev/null; then
    log_output "apt: Available"
    log_output "apt list --installed 2>/dev/null | head -20:"
    apt list --installed 2>/dev/null | head -20 >> $OUTPUT_FILE
else
    log_output "apt: Not available"
fi

if command -v yum &> /dev/null; then
    log_output "yum: Available"
else
    log_output "yum: Not available"
fi

if command -v pip3 &> /dev/null; then
    log_output "pip3: Available"
    log_output "pip3 list:"
    pip3 list >> $OUTPUT_FILE 2>&1
else
    log_output "pip3: Not available"
fi
log_output ""

# Web Server Configuration
log_output "=== WEB SERVER ==="
if [ -d "/etc/apache2" ]; then
    log_output "Apache2 configuration found"
    log_output "Apache modules available:"
    if [ -r "/etc/apache2/mods-available" ]; then
        ls /etc/apache2/mods-available/*.load 2>/dev/null | head -20 >> $OUTPUT_FILE
    fi
    if [ -r "/etc/apache2/mods-enabled" ]; then
        log_output "Apache modules enabled:"
        ls /etc/apache2/mods-enabled/*.load 2>/dev/null >> $OUTPUT_FILE
    fi
elif [ -d "/etc/httpd" ]; then
    log_output "HTTPD configuration found"
fi

# Check Apache user directory settings
log_output ""
log_output "User public_html status:"
if [ -d "$HOME/public_html" ]; then
    log_output "~/public_html exists"
    ls -la $HOME/public_html | head -5 >> $OUTPUT_FILE
else
    log_output "~/public_html does not exist"
fi

# Check .htaccess capabilities
log_output ""
log_output "=== HTACCESS CAPABILITIES ==="
echo "Options +ExecCGI
AddHandler cgi-script .cgi .pl .py
DirectoryIndex index.html" > test.htaccess
if [ -f test.htaccess ]; then
    log_output ".htaccess file creation: Success"
    rm test.htaccess
else
    log_output ".htaccess file creation: Failed"
fi

# Programming Languages
log_output ""
log_output "=== PROGRAMMING LANGUAGES ==="

# Python
if command -v python3 &> /dev/null; then
    log_output "Python3: $(python3 --version)"
    log_output "Python3 path: $(which python3)"
    log_output "Python3 modules:"
    python3 -c "import sys; print('\n'.join(sys.modules.keys()))" 2>/dev/null | grep -E "(cgi|http|sqlite|flask|django)" | sort | uniq >> $OUTPUT_FILE
else
    log_output "Python3: Not found"
fi

# PHP
if command -v php &> /dev/null; then
    log_output "PHP: $(php --version | head -1)"
    log_output "PHP modules:"
    php -m 2>/dev/null | head -20 >> $OUTPUT_FILE
else
    log_output "PHP: Not found"
fi

# Perl
if command -v perl &> /dev/null; then
    log_output "Perl: $(perl --version | head -2 | tail -1)"
else
    log_output "Perl: Not found"
fi

# Ruby
if command -v ruby &> /dev/null; then
    log_output "Ruby: $(ruby --version)"
else
    log_output "Ruby: Not found"
fi

# Node.js
if command -v node &> /dev/null; then
    log_output "Node.js: $(node --version)"
else
    log_output "Node.js: Not found"
fi

# Database Access
log_output ""
log_output "=== DATABASE TOOLS ==="

if command -v sqlite3 &> /dev/null; then
    log_output "SQLite3: $(sqlite3 --version)"
else
    log_output "SQLite3: Not found"
fi

if command -v mysql &> /dev/null; then
    log_output "MySQL client: $(mysql --version)"
else
    log_output "MySQL client: Not found"
fi

if command -v psql &> /dev/null; then
    log_output "PostgreSQL client: $(psql --version)"
else
    log_output "PostgreSQL client: Not found"
fi

# CGI Testing
log_output ""
log_output "=== CGI CAPABILITY TEST ==="

# Test CGI with Python
mkdir -p cgi-test
cat > cgi-test/test.py << 'EOF'
#!/usr/bin/env python3
print("Content-Type: text/html\n")
print("<html><body>")
print("<h1>Python CGI Test Success</h1>")
print("<p>If you see this, Python CGI is working!</p>")
print("</body></html>")
EOF
chmod 755 cgi-test/test.py

# Test CGI with Shell
cat > cgi-test/test.sh << 'EOF'
#!/bin/bash
echo "Content-Type: text/html"
echo ""
echo "<html><body>"
echo "<h1>Shell CGI Test Success</h1>"
echo "<p>If you see this, Shell CGI is working!</p>"
echo "</body></html>"
EOF
chmod 755 cgi-test/test.sh

log_output "Created test CGI scripts in cgi-test/"
log_output "Try accessing: http://your-domain/~username/parking-dbms/cgi-test/test.py"

# File Permissions
log_output ""
log_output "=== FILE PERMISSIONS ==="
log_output "Current directory permissions:"
ls -la . | head -10 >> $OUTPUT_FILE

# Process Limits
log_output ""
log_output "=== PROCESS LIMITS ==="
ulimit -a >> $OUTPUT_FILE 2>&1

# Network Ports
log_output ""
log_output "=== NETWORK ACCESS ==="
log_output "Can bind to ports:"
# Try to check if we can bind to high ports
python3 -c "
import socket
ports_to_test = [8080, 8000, 3000, 5000]
for port in ports_to_test:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind(('', port))
        s.close()
        print(f'Port {port}: Can bind')
    except:
        print(f'Port {port}: Cannot bind')
" >> $OUTPUT_FILE 2>&1

# Check for WebSocket support
log_output ""
log_output "=== ADVANCED WEB FEATURES ==="
python3 -c "
import importlib
modules = ['websocket', 'tornado', 'asyncio', 'aiohttp', 'wsgiref']
for mod in modules:
    try:
        importlib.import_module(mod)
        print(f'{mod}: Available')
    except:
        print(f'{mod}: Not available')
" >> $OUTPUT_FILE 2>&1

# SQLite Web Interface possibilities
log_output ""
log_output "=== SQLITE WEB INTERFACE OPTIONS ==="

# Check if we can use Python's built-in HTTP server
python3 -c "
import http.server
import socketserver
print('Python http.server: Available')
" >> $OUTPUT_FILE 2>&1

# JavaScript capabilities
log_output ""
log_output "=== CLIENT-SIDE POSSIBILITIES ==="
log_output "Can use JavaScript with:"
log_output "- IndexedDB for client-side storage"
log_output "- WebSQL (deprecated but might work)"
log_output "- LocalStorage for simple data"
log_output "- Service Workers for offline functionality"
log_output "- Fetch API for AJAX-like requests"

# Alternative approaches
log_output ""
log_output "=== ALTERNATIVE APPROACHES ==="
log_output "1. Pure client-side with sql.js (SQLite in browser)"
log_output "2. Static site generator with pre-built pages"
log_output "3. GitHub Pages with GitHub Actions for data updates"
log_output "4. Netlify/Vercel with serverless functions"
log_output "5. Client-side frameworks (Vue, React) with IndexedDB"

# Summary
log_output ""
log_output "=== SUMMARY ==="
log_output "Analysis complete. Check $OUTPUT_FILE for full details."
log_output ""
log_output "Next steps:"
log_output "1. Test CGI scripts if Apache allows"
log_output "2. Explore client-side database solutions"
log_output "3. Consider static generation approach"
log_output "4. Test Python simple HTTP server on high ports"

echo ""
echo "Analysis complete! Results saved to: $OUTPUT_FILE"
echo "Upload this file after running on school server for analysis."