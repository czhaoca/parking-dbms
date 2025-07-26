#!/bin/bash
# Fix permissions for Apache deployment on UBC server

echo "Fixing permissions for Apache deployment..."

# Set directory permissions (755 = rwxr-xr-x)
find . -type d -exec chmod 755 {} \;
echo "✓ Directory permissions set to 755"

# Set file permissions (644 = rw-r--r--)
find . -type f -exec chmod 644 {} \;
echo "✓ File permissions set to 644"

# Make scripts executable if needed
chmod 755 fix-permissions.sh 2>/dev/null
echo "✓ Script permissions updated"

# Special permissions for .htaccess (must be readable by Apache)
chmod 644 .htaccess
echo "✓ .htaccess permissions set to 644"

# Protect sensitive files (but still readable by owner)
chmod 600 .env 2>/dev/null
echo "✓ .env permissions set to 600 (if exists)"

# Ensure utils directory is accessible
chmod 755 utils/
echo "✓ utils directory permissions set to 755"

# Set permissions for all PHP files to be readable
find . -name "*.php" -exec chmod 644 {} \;
echo "✓ PHP file permissions set to 644"

echo ""
echo "Permissions fixed! If you still see errors, check:"
echo "1. Your home directory permissions: chmod 711 ~"
echo "2. Your public_html permissions: chmod 755 ~/public_html"
echo "3. Project directory permissions: chmod 755 ~/public_html/parking-dbms"