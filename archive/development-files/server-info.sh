#!/bin/bash
# Script to gather server information and installed packages
# Run this on the UBC server to see what's available

OUTPUT_FILE="server-info.txt"

echo "=== Server Information Collection ===" | tee $OUTPUT_FILE
echo "Date: $(date)" | tee -a $OUTPUT_FILE
echo "User: $(whoami)" | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== System Information ===" | tee -a $OUTPUT_FILE
uname -a | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== OS Version ===" | tee -a $OUTPUT_FILE
if [ -f /etc/os-release ]; then
    cat /etc/os-release | tee -a $OUTPUT_FILE
else
    echo "No /etc/os-release found" | tee -a $OUTPUT_FILE
fi
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for PHP ===" | tee -a $OUTPUT_FILE
echo "which php:" | tee -a $OUTPUT_FILE
which php 2>&1 | tee -a $OUTPUT_FILE
echo "php version:" | tee -a $OUTPUT_FILE
php -v 2>&1 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for other PHP versions ===" | tee -a $OUTPUT_FILE
for ver in php7.0 php7.1 php7.2 php7.3 php7.4 php8.0 php8.1 php8.2 php8.3; do
    echo "Checking $ver:" | tee -a $OUTPUT_FILE
    which $ver 2>&1 | tee -a $OUTPUT_FILE
done
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for Python ===" | tee -a $OUTPUT_FILE
echo "which python3:" | tee -a $OUTPUT_FILE
which python3 2>&1 | tee -a $OUTPUT_FILE
echo "python3 version:" | tee -a $OUTPUT_FILE
python3 --version 2>&1 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for Node.js ===" | tee -a $OUTPUT_FILE
echo "which node:" | tee -a $OUTPUT_FILE
which node 2>&1 | tee -a $OUTPUT_FILE
echo "node version:" | tee -a $OUTPUT_FILE
node --version 2>&1 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for Ruby ===" | tee -a $OUTPUT_FILE
echo "which ruby:" | tee -a $OUTPUT_FILE
which ruby 2>&1 | tee -a $OUTPUT_FILE
echo "ruby version:" | tee -a $OUTPUT_FILE
ruby --version 2>&1 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for Perl ===" | tee -a $OUTPUT_FILE
echo "which perl:" | tee -a $OUTPUT_FILE
which perl 2>&1 | tee -a $OUTPUT_FILE
echo "perl version:" | tee -a $OUTPUT_FILE
perl --version 2>&1 | head -n 2 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Apache Information ===" | tee -a $OUTPUT_FILE
echo "Apache version:" | tee -a $OUTPUT_FILE
apache2 -v 2>&1 | tee -a $OUTPUT_FILE
echo "Apache modules (if accessible):" | tee -a $OUTPUT_FILE
apache2ctl -M 2>&1 | head -n 20 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Installed Packages (if dpkg available) ===" | tee -a $OUTPUT_FILE
if command -v dpkg &> /dev/null; then
    echo "Total packages: $(dpkg -l | wc -l)" | tee -a $OUTPUT_FILE
    echo "Web-related packages:" | tee -a $OUTPUT_FILE
    dpkg -l | grep -E 'apache|php|python|perl|ruby|node|nginx|web' | head -n 50 | tee -a $OUTPUT_FILE
else
    echo "dpkg not available or no permission" | tee -a $OUTPUT_FILE
fi
echo "" | tee -a $OUTPUT_FILE

echo "=== Available commands in PATH ===" | tee -a $OUTPUT_FILE
echo "Looking for web development tools..." | tee -a $OUTPUT_FILE
for cmd in gcc g++ make git svn mysql psql sqlite3 mongo redis-cli docker podman; do
    if command -v $cmd &> /dev/null; then
        echo "✓ $cmd is available: $(which $cmd)" | tee -a $OUTPUT_FILE
    fi
done
echo "" | tee -a $OUTPUT_FILE

echo "=== User Environment ===" | tee -a $OUTPUT_FILE
echo "Home directory: $HOME" | tee -a $OUTPUT_FILE
echo "Current directory: $(pwd)" | tee -a $OUTPUT_FILE
echo "Shell: $SHELL" | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== Web Directory Permissions ===" | tee -a $OUTPUT_FILE
ls -la ~/public_html/ 2>&1 | head -n 10 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "=== CGI-BIN Check ===" | tee -a $OUTPUT_FILE
if [ -d ~/public_html/cgi-bin ]; then
    echo "CGI-BIN exists" | tee -a $OUTPUT_FILE
    ls -la ~/public_html/cgi-bin/ 2>&1 | head -n 5 | tee -a $OUTPUT_FILE
else
    echo "No CGI-BIN directory found" | tee -a $OUTPUT_FILE
fi
echo "" | tee -a $OUTPUT_FILE

echo "=== Check for alternative scripting support ===" | tee -a $OUTPUT_FILE
echo "Checking .htaccess in public_html:" | tee -a $OUTPUT_FILE
if [ -f ~/public_html/.htaccess ]; then
    head -n 10 ~/public_html/.htaccess 2>&1 | tee -a $OUTPUT_FILE
else
    echo "No .htaccess in public_html root" | tee -a $OUTPUT_FILE
fi
echo "" | tee -a $OUTPUT_FILE

echo "=== Summary ===" | tee -a $OUTPUT_FILE
echo "Script completed. Results saved to: $OUTPUT_FILE" | tee -a $OUTPUT_FILE
echo "Please add this file to git and commit it." | tee -a $OUTPUT_FILE