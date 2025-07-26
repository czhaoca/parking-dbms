# PHP Setup Guide for UBC Servers

## Problem
PHP files are displaying as plain text instead of being executed.

## Immediate Steps

1. **Remove or rename .htaccess**
   ```bash
   cd ~/public_html/parking-dbms
   mv .htaccess .htaccess.disabled
   ```

2. **Test basic PHP**
   Access: `https://www.students.cs.ubc.ca/~yourusername/parking-dbms/test.php`
   - If it shows "PHP works" → PHP is enabled
   - If it shows `<?php echo "PHP works"; ?>` → PHP is NOT enabled

3. **Try the HTML interface**
   Access: `https://www.students.cs.ubc.ca/~yourusername/parking-dbms/index.html`
   This provides instructions and testing tools.

## Server-Specific Solutions

### For students.cs.ubc.ca

1. **Check if PHP is available**
   ```bash
   ssh yourusername@students.cs.ubc.ca
   which php
   php -v
   ```

2. **Check your quota**
   ```bash
   quota -v
   ```

3. **Verify file permissions**
   ```bash
   ls -la ~/public_html/
   ls -la ~/public_html/parking-dbms/
   ```

### Common UBC Server Configurations

1. **Option A: PHP might be in cgi-bin only**
   ```bash
   mkdir -p ~/public_html/cgi-bin
   cp *.php ~/public_html/cgi-bin/
   chmod 755 ~/public_html/cgi-bin/*.php
   ```

2. **Option B: Use .php.cgi extension**
   ```bash
   mv index.php index.php.cgi
   chmod 755 index.php.cgi
   ```

3. **Option C: Create custom .htaccess**
   Create a new `.htaccess` with only:
   ```apache
   Options +ExecCGI
   AddHandler cgi-script .php
   ```

## Contact Support Template

Send this to your system administrator:

```
Subject: Enable PHP for Database Course Project

Hello,

I'm a student in [Course Number] and need PHP enabled for my course project.

Details:
- Username: [your_username]
- Project: Parking Management System (Database course)
- Location: ~/public_html/parking-dbms/
- Requirements: PHP 7.4+ with OCI8 extension

Currently, PHP files are showing as plain text instead of executing.

Could you please:
1. Enable PHP for my public_html directory
2. Ensure OCI8 extension is available for Oracle database connectivity

Thank you for your assistance.

Best regards,
[Your Name]
[Student Number]
```

## Alternative Solutions

### 1. Local Development
- Install [XAMPP](https://www.apachefriends.org/) (Windows/Mac/Linux)
- Install [Oracle Instant Client](https://www.oracle.com/database/technologies/instant-client.html)
- Clone the repository locally

### 2. Free PHP Hosting
- [000webhost](https://www.000webhost.com/)
- [InfinityFree](https://infinityfree.net/)
- Note: These may not support Oracle databases

### 3. Docker Setup
```bash
# Create a Dockerfile
FROM php:7.4-apache
RUN docker-php-ext-install oci8
COPY . /var/www/html/
```

## Verification Steps

Once PHP is enabled:

1. Test basic PHP: `/test.php`
2. Test PHP info: `/phpinfo.php`
3. Check OCI8: Look for OCI8 section in phpinfo
4. Test database connection: Update `.env` and test

## Important Notes

- Never commit `.env` files with real credentials
- Remove `phpinfo.php` in production
- Some servers disable certain PHP functions for security
- Oracle connections may require additional firewall rules