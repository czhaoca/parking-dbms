# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PHP-based Parking Management System that uses Oracle Database for data storage. The application manages employee parking allocations, EV charging bookings, and parking waitlists for an organization.

## Database Architecture

The system uses Oracle Database with the following main tables:
- **buildingInfo**: Buildings and their parking capacity
- **departmentInfo**: Departments linked to buildings
- **employeeInfo**: Employee records with department assignments
- **loginInfo**: User authentication and authorization
- **parkingInfo**: Parking spot allocations
- **evBook**: EV charging station bookings
- **parkingWaitList**: Waiting list for parking spots

All table definitions and sample data are in `src/parkingdata.sql`.

## Running the Application

Since this is a PHP application that requires an Oracle database connection:

1. **Database Setup**: Execute `src/parkingdata.sql` to create tables and insert sample data
2. **Web Server**: Deploy PHP files to a web server with Oracle OCI8 extension enabled
3. **Access**: Navigate to `index.php` for the main menu

## Key Components

### Report Pages (Root Directory)
- `employeeStatusReport.php`: Generate PT/FT employee lists
- `displayEmployee.php`: Display all employees
- `displayWaitList.php`: Show parking waitlist
- `displayYoung.php`: Find youngest employee
- `displayWaitListEmployee.php`: Employees still waiting for parking

### Database Maintenance Pages (utils/)
Each table has a maintenance page with CRUD operations:
- Insert new records
- Update existing records
- Delete records
- Count and display tuples

### Database Connection
All PHP files use Oracle OCI functions with connection details:
- Server: `dbhost.students.cs.ubc.ca:1522/stu`
- Username format: `ora_[username]`
- Password format: `a[student_number]`

## Development Notes

- The application uses plain SQL with bound parameters for security
- All database operations use OCI functions (OCIParse, OCIExecute, OCICommit)
- Error handling displays Oracle error messages when operations fail
- The `test/` directory contains database connection test files