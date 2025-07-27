#!/bin/bash
# Parking Database Management System - Server Startup Script

echo "Parking Database Management System"
echo "=================================="
echo ""

# Check if running as root for port 80
if [ "$EUID" -ne 0 ] && [ "${1:-80}" -eq 80 ]; then 
    echo "Error: Port 80 requires root privileges"
    echo "Please run: sudo ./start-server.sh"
    echo ""
    echo "Or use a different port: ./start-server.sh 8080"
    exit 1
fi

# Default to port 80, or use provided port
PORT=${1:-80}

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

echo "Starting server on port $PORT..."
echo ""

# Check which mode to use
if [ -f "app.py" ]; then
    echo "Starting Python API server with SQLite database..."
    echo "This provides full CRUD functionality"
    echo ""
    
    # Update port in app.py if needed
    if [ "$PORT" != "80" ]; then
        sed -i.bak "s/PORT = 80/PORT = $PORT/" app.py
    fi
    
    python3 app.py
else
    echo "Starting static file server..."
    echo "This provides SQL command generation only"
    echo ""
    
    # Update port in serve.py if needed
    if [ "$PORT" != "80" ]; then
        sed -i.bak "s/PORT = 80/PORT = $PORT/" serve.py
    fi
    
    python3 serve.py
fi