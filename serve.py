#!/usr/bin/env python3
"""
Simple HTTP server for parking database management system
Serves static HTML files on port 80
"""

import http.server
import socketserver
import os
import sys

PORT = 80
DIRECTORY = "/work/parking-dbms"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Add headers for better compatibility
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Expires', '0')
        super().end_headers()

def main():
    os.chdir(DIRECTORY)
    
    try:
        with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
            print(f"Parking Database Management System")
            print(f"Server running at http://localhost:{PORT}/")
            print(f"Serving files from: {DIRECTORY}")
            print("Press Ctrl+C to stop the server")
            httpd.serve_forever()
    except PermissionError:
        print(f"Error: Permission denied to bind to port {PORT}")
        print("Try running with sudo: sudo python3 serve.py")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nServer stopped.")
        sys.exit(0)

if __name__ == "__main__":
    main()