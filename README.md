# Parking Management System

A comprehensive PHP-based parking management system designed for corporate environments, featuring employee parking allocation, EV charging station booking, and waitlist management.

## Features

- **Employee Management**: Track full-time and part-time employees across departments
- **Parking Allocation**: Manage parking spot assignments with building-based capacity
- **EV Charging**: Book electric vehicle charging stations with time slots
- **Waitlist System**: Automated waitlist for parking spots when capacity is full
- **Admin Dashboard**: Comprehensive reporting and management tools
- **Role-Based Access**: Separate permissions for users and administrators

## Technology Stack

- **Backend**: PHP 7.4+ with OCI8 extension
- **Database**: Oracle Database (Compatible with OCI Free Tier Autonomous Database)
- **Frontend**: HTML, CSS, JavaScript
- **Server**: Apache/Nginx with PHP support

## Database Schema

The system uses 7 main tables:

- `buildingInfo`: Buildings and parking capacity
- `departmentInfo`: Department-building relationships
- `employeeInfo`: Employee records
- `loginInfo`: Authentication and authorization
- `parkingInfo`: Parking spot allocations
- `evBook`: EV charging bookings
- `parkingWaitList`: Parking waitlist queue

## Installation

### Prerequisites

1. PHP 7.4 or higher with OCI8 extension
2. Oracle Instant Client
3. Web server (Apache/Nginx)
4. Oracle Cloud account (for Free Tier Autonomous Database)

### Database Setup

1. **Create Oracle Autonomous Database**
   - Sign up for [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
   - Create an Autonomous Database (Always Free: 1 OCPU, 20GB storage)
   - Choose **19c** version with **Transaction Processing** workload
   - Download the wallet file from OCI Console

2. **Configure Database Connection**
   - Extract wallet to secure directory (e.g., `/opt/oracle/wallet`)
   - Set `TNS_ADMIN` environment variable to wallet path:
     ```bash
     export TNS_ADMIN=/opt/oracle/wallet
     ```
   - Copy `.env.example` to `.env` and update with your credentials:
     ```bash
     cp .env.example .env
     # Edit .env with your database credentials
     ```

3. **Run Migration Script**
   ```bash
   # Connect as ADMIN to create application user
   sqlplus admin/your_admin_password@your_tns_name @src/migrate_to_oci.sql
   ```

### Application Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/czhaoca/parking-dbms.git
   cd parking-dbms
   ```

2. **Configure Apache Web Server**
   
   For UBC hosting (Apache/2.4.58 Ubuntu):
   ```bash
   # First, ensure your home directory allows Apache access
   chmod 711 ~
   chmod 755 ~/public_html
   
   # Copy files to your public_html directory
   cp -r * ~/public_html/parking-dbms/
   
   # Run the permission fix script
   cd ~/public_html/parking-dbms/
   chmod 755 fix-permissions.sh
   ./fix-permissions.sh
   
   # Or manually set permissions:
   find ~/public_html/parking-dbms -type d -exec chmod 755 {} \;
   find ~/public_html/parking-dbms -type f -exec chmod 644 {} \;
   chmod 600 ~/public_html/parking-dbms/.env
   ```
   
   For other Apache servers:
   - Point document root to project directory
   - Ensure PHP OCI8 extension is enabled
   - Enable mod_rewrite and mod_headers modules
   - The included `.htaccess` file handles security and configuration

3. **Update Configuration**
   - Copy `.env.example` to `.env`
   - Update database credentials in `.env`
   - Ensure `.env` has proper permissions (chmod 600)
   - Set `TNS_ADMIN` environment variable to wallet directory

4. **Verify Installation**
   ```bash
   # Check PHP extensions
   php -m | grep oci8
   
   # Test database connection
   php src/config/db_config_oci.php
   ```

5. **Access Application**
   - Navigate to `https://your-domain/parking-dbms/`
   - The `.htaccess` file ensures proper routing
   - Default admin users: sharon, jimmy, tom, jess (check loginInfo table)

## Usage

### For Administrators

1. **Employee Management**
   - Add/edit/remove employees
   - Assign departments and parking spots
   - Generate employee reports

2. **Parking Management**
   - Monitor parking capacity
   - Assign/revoke parking spots
   - Manage EV charging stations

3. **Reports**
   - Employee status reports (FT/PT)
   - Parking utilization
   - Waitlist status
   - EV booking history

### For Employees

1. **Login** with assigned credentials
2. **View** parking assignment
3. **Book** EV charging slots
4. **Join** parking waitlist if needed

## Project Structure

```
parking-dbms/
├── index.php                 # Main entry point
├── displayEmployee.php       # Employee listing
├── displayWaitList.php       # Waitlist display
├── displayYoung.php          # Youngest employee report
├── employeeStatusReport.php  # FT/PT employee reports
├── src/
│   ├── parkingdata.sql      # Original database schema
│   ├── migrate_to_oci.sql   # OCI migration script
│   └── config/
│       └── db_config_oci.php # Database configuration
├── utils/                    # Database maintenance pages
├── test/                     # Database connection tests
├── CLAUDE.md                # AI assistant instructions
└── README.md                # This file
```

## Security Considerations

- **Never commit credentials** - Use environment variables or .env files
- **Protect .env file** - Ensure it's in .gitignore and has restricted permissions
- Store wallet files securely outside web root
- Use strong passwords meeting Oracle requirements (12+ chars, mixed case, numbers, symbols)
- Implement HTTPS for production deployment
- Regular security updates for PHP and dependencies
- Input validation and parameterized queries
- Session management and timeout policies

## Apache Hosting Requirements

- Apache 2.4+ with mod_php
- PHP 7.4+ with OCI8 extension
- mod_rewrite enabled
- mod_headers enabled (optional, for security headers)
- AllowOverride All for .htaccess to work

## Troubleshooting

### Common Issues

1. **OCI8 Extension Not Found**
   - Install Oracle Instant Client
   - Enable OCI8 in php.ini
   - Restart Apache: `sudo systemctl restart apache2`

2. **Database Connection Failed**
   - Verify TNS_ADMIN environment variable
   - Check wallet file permissions
   - Validate credentials in .env file
   - Ensure wallet directory is readable by Apache user

3. **Permission Errors**
   ```bash
   # Fix permissions
   find . -type d -exec chmod 755 {} \;
   find . -type f -exec chmod 644 {} \;
   chmod 600 .env
   ```

4. **Apache 403 Forbidden / "Server unable to read htaccess file"**
   ```bash
   # This is the most common issue - fix with:
   chmod 711 ~                              # Home directory
   chmod 755 ~/public_html                  # Public HTML directory
   chmod 755 ~/public_html/parking-dbms     # Project directory
   chmod 644 ~/public_html/parking-dbms/.htaccess  # Make .htaccess readable
   
   # Run the fix script:
   cd ~/public_html/parking-dbms && ./fix-permissions.sh
   ```

5. **PHP Files Download Instead of Execute (Shows Raw Code)**
   
   This is a critical issue. Try these solutions in order:
   
   a) **Test if PHP works at all:**
   ```bash
   # Access the test file
   https://your-domain/parking-dbms/phpinfo.php
   ```
   
   b) **Temporarily disable .htaccess:**
   ```bash
   cd ~/public_html/parking-dbms
   mv .htaccess .htaccess.bak
   # Try accessing index.php again
   ```
   
   c) **If PHP works without .htaccess, try different handlers in .htaccess:**
   - Edit .htaccess and try uncommenting different PHP handler options
   - Option 1: SetHandler application/x-httpd-php
   - Option 2: AddHandler application/x-httpd-php .php
   - Option 3: AddType application/x-httpd-php .php
   
   d) **Check Apache PHP module:**
   ```bash
   # Check if PHP module is loaded (if you have access)
   apache2ctl -M | grep php
   # or
   httpd -M | grep php
   ```
   
   e) **Last resort - No .htaccess approach:**
   - Remove/rename .htaccess file
   - PHP should work with Apache's default configuration
   - Contact system administrator to enable PHP for your account

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Changelog

### [2.0.0] - 2025-07-26
#### Added
- Oracle Cloud Infrastructure (OCI) Free Tier support
- Autonomous Database migration script
- Enhanced database configuration with connection pooling
- Database views for common queries
- Comprehensive README documentation
- Environment variable support for credentials
- .gitignore for security and cleanliness

#### Changed
- Migrated from UBC Solaris Oracle to OCI Autonomous Database
- Updated database schema with proper constraints and indexes
- Improved error handling and logging
- Modernized PHP database connection methods

#### Removed
- Legacy UBC database connection strings
- Deprecated grant statements for public access

### [1.0.0] - Initial Release
- Basic parking management functionality
- Employee and department management
- Parking allocation system
- EV charging booking
- Waitlist management
- Admin reporting tools

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Originally developed for UBC database course
- Migrated to modern cloud infrastructure
- Built with PHP and Oracle Database technologies