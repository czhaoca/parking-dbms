# Parking Database Management System

A comprehensive database management system for corporate parking allocation, built as a course project demonstrating database design and implementation principles.

## Project Evolution

This project was developed for a UBC database course in 2022. When the course ended, access to PHP and Oracle Database services was terminated. The project has been migrated to Python with SQLite to preserve functionality and serve as a portfolio piece.

## Features

- **Employee Management**: Track full-time and part-time employees with department assignments
- **Parking Allocation**: Manage parking spot assignments with EV charging capabilities
- **Waitlist System**: Automated waitlist for parking spot requests
- **Reporting**: Generate reports on parking utilization, employee status, and more
- **Multi-Mode Operation**: Works with both SQLite (Python API) and Oracle (SQL generator)

## Quick Start

### Option 1: Python API Mode (Recommended)
Full CRUD functionality with SQLite database:

```bash
# Start server on port 80 (requires sudo)
sudo ./start-server.sh

# Or use a different port
./start-server.sh 8080
```

Then open: http://localhost/ or http://localhost:8080/

### Option 2: Static SQL Generator Mode
For environments without Python API support:

```bash
# Remove app.py to use static mode
mv app.py app.py.bak
./start-server.sh
```

## System Requirements

- Python 3.x
- Port 80 access (or configure alternative port)
- Modern web browser

## Project Structure

```
parking-dbms/
├── index.html          # Static SQL generator interface
├── index-api.html      # Full API-enabled interface
├── app.py              # Python API server with SQLite
├── serve.py            # Simple static file server
├── start-server.sh     # Unified startup script
├── parking.db          # SQLite database (auto-created)
├── src/
│   └── parkingdata.sql # Original Oracle schema and data
├── archive/            # Historical PHP implementation
└── test/               # Test files
```

## Database Schema

The system uses 7 interconnected tables:

1. **buildingInfo**: Buildings and parking capacity
2. **departmentInfo**: Department-building relationships
3. **employeeInfo**: Employee records
4. **loginInfo**: User authentication
5. **parkingInfo**: Parking spot allocations
6. **evBook**: EV charging station bookings
7. **parkingWaitList**: Parking waitlist queue

## Operating Modes

### API Mode (Python + SQLite)
- Real-time database operations
- Add, update, delete records
- Live data visualization
- Automatic SQLite database creation

### SQL Generator Mode
- Generate SQL commands for Oracle database
- Copy commands to execute in SQL*Plus or SQL Developer
- No direct database connection required
- Works in restricted environments

## Deployment Options

### Local Development
```bash
./start-server.sh 8080
```

### Production (Port 80)
```bash
sudo ./start-server.sh
```

### Apache Web Server
1. Copy all files to web directory
2. Ensure .htaccess is properly configured
3. Access via web browser

## API Endpoints (API Mode)

- `GET /api/status` - Database statistics
- `GET /api/employees` - List all employees
- `GET /api/parking` - Parking spot status
- `GET /api/reports` - Generate reports
- `POST /api/employee/add` - Add new employee
- `POST /api/parking/assign` - Assign parking spot

## Browser Compatibility

The application uses standard HTML5, CSS3, and vanilla JavaScript for maximum compatibility. No external frameworks required.

## Security Notes

- The .htaccess file prevents access to sensitive files
- SQL injection prevention through parameterized queries (API mode)
- No database credentials stored in client-side code

## Troubleshooting

1. **Port 80 Permission Denied**
   - Use sudo: `sudo ./start-server.sh`
   - Or use alternative port: `./start-server.sh 8080`

2. **Python Not Found**
   - Install Python 3: `apt-get install python3`

3. **Database Not Created**
   - Delete parking.db and restart server
   - Check src/parkingdata.sql exists

## Original Implementation

This project was originally developed using PHP and Oracle Database for a database course. The current implementation maintains the same functionality while supporting modern deployment environments.

## License

Educational project - for demonstration purposes only.