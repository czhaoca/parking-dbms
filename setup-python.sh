#!/bin/bash
# Setup script for Python-based Parking Management System on UBC servers

echo "=== Setting up Python-based Parking Management System ==="
echo ""

# Make scripts executable
chmod +x cgi-bin/*.py
chmod +x python_app/deploy.sh

# Check which Python approach will work
echo "Checking server capabilities..."
echo ""

# Option 1: CGI Scripts (most likely to work)
echo "Option 1: CGI Scripts"
echo "-------------------"
if [ -d ~/public_html ]; then
    echo "✓ public_html directory exists"
    
    # Create cgi-bin if it doesn't exist
    mkdir -p ~/public_html/cgi-bin
    
    # Copy CGI scripts
    cp -r cgi-bin/* ~/public_html/cgi-bin/
    chmod 755 ~/public_html/cgi-bin
    chmod 755 ~/public_html/cgi-bin/*.py
    
    echo "✓ CGI scripts copied to ~/public_html/cgi-bin/"
    echo "  Try accessing: https://www.students.cs.ubc.ca/~$USER/cgi-bin/index.py"
else
    echo "✗ No public_html directory found"
fi

echo ""
echo "Option 2: Flask App (requires port access)"
echo "-----------------------------------------"
cd python_app
if command -v python3 &> /dev/null; then
    echo "✓ Python 3 is available"
    
    # Check if we can create virtual environment
    python3 -m venv test_venv 2>/dev/null
    if [ -d "test_venv" ]; then
        echo "✓ Can create virtual environments"
        rm -rf test_venv
        
        # Run deployment
        bash deploy.sh
    else
        echo "✗ Cannot create virtual environments"
        echo "  Installing packages globally (if permitted)..."
        pip3 install --user -r requirements.txt 2>/dev/null || echo "✗ Cannot install packages"
    fi
else
    echo "✗ Python 3 not available"
fi

cd ..

echo ""
echo "Option 3: Static HTML + JavaScript"
echo "----------------------------------"
echo "The index.html file already provides a static interface"
echo "Access it at: https://www.students.cs.ubc.ca/~$USER/parking-dbms/"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Try the CGI version: https://www.students.cs.ubc.ca/~$USER/cgi-bin/index.py"
echo "2. If CGI doesn't work, use the static HTML interface"
echo "3. For Flask app, you'll need to request a port from sysadmin"
echo ""
echo "To test locally:"
echo "- cd python_app && python3 app.py"
echo "- Access http://localhost:5000"