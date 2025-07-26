#!/bin/bash
# Deployment script for Python Flask app on UBC servers

echo "=== Parking Management System - Python Deployment ==="
echo ""

# Check Python version
echo "Checking Python installation..."
python3 --version

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Initialize database if needed
if [ ! -f "parking.db" ]; then
    echo "Initializing database..."
    python3 -c "from app import init_db; init_db()"
fi

# Create run script
cat > run.sh << 'EOF'
#!/bin/bash
source venv/bin/activate
export FLASK_APP=app.py
export FLASK_ENV=production

# For development/testing
# flask run --host=0.0.0.0 --port=5000

# For production with gunicorn
gunicorn -w 2 -b 0.0.0.0:5000 app:app
EOF

chmod +x run.sh

# Create systemd service file (for reference)
cat > parking-app.service << 'EOF'
[Unit]
Description=Parking Management System
After=network.target

[Service]
User=czha
WorkingDirectory=/home/c/czha/public_html/parking-dbms/python_app
Environment="PATH=/home/c/czha/public_html/parking-dbms/python_app/venv/bin"
ExecStart=/home/c/czha/public_html/parking-dbms/python_app/venv/bin/gunicorn -w 2 -b 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "To run the application:"
echo "1. ./run.sh                    # Run with gunicorn"
echo "2. python3 app.py             # Run in development mode"
echo ""
echo "The app will be available at http://localhost:5000"
echo ""
echo "Note: Since this runs as a separate web server, you'll need to:"
echo "- Set up a reverse proxy in Apache, or"
echo "- Run on a different port and access directly"
echo "- Contact sysadmin for port forwarding/proxy setup"