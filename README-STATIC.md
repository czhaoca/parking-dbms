# Parking Database Management System - Static Version

## Overview
This is a completely client-side version of the Parking Database Management System that requires **NO server-side execution**. It works with just Apache serving static HTML files.

## Features
- **100% Client-Side**: All functionality runs in the browser using JavaScript
- **LocalStorage Database**: Data persists between sessions in browser storage
- **Import/Export**: Save and load database as JSON files
- **Full CRUD Operations**: Add, view, update, and delete records
- **No Dependencies**: No PHP, Python, CGI, or database server needed

## Quick Start

1. **Upload Files**: Copy all files to your web directory
2. **Run Setup** (optional): `./setup-static.sh` to set permissions
3. **Access**: Open `http://your-domain/parking-dbms/app.html`

That's it! No server configuration needed.

## Available Interfaces

### 1. Client-Side Database App (`app.html`)
- Full database functionality in the browser
- Data stored in localStorage
- Import/Export JSON files
- Works offline after initial load

### 2. SQL Generator (`index.html`)  
- Generate SQL commands for Oracle
- Copy and paste into SQL*Plus
- No data storage

### 3. API Version (`index-api.html`)
- For servers with Python/CGI support
- Requires additional setup

## How It Works

The application uses browser localStorage to store data:
- **Persistent**: Data survives browser restarts
- **Local**: Data stays on the user's computer
- **Private**: Each browser has its own database
- **Portable**: Export/import as JSON files

## File Structure
```
parking-dbms/
├── app.html            # Main client-side application
├── index.html          # SQL command generator
├── .htaccess           # Apache configuration (minimal)
├── setup-static.sh     # Simple setup script
└── README-STATIC.md    # This file
```

## Browser Compatibility
Works on all modern browsers:
- Chrome 4+
- Firefox 3.5+
- Safari 4+
- Edge (all versions)
- Opera 10.5+

## Data Management

### Export Data
1. Click "Export Database" button
2. Save the JSON file
3. Share or backup as needed

### Import Data
1. Click "Import Database" button
2. Select a JSON file
3. Data replaces current database

### Clear Data
1. Click "Clear All Data" button
2. Confirm the action
3. Database is reset

## Limitations
- Data is browser-specific (not shared between devices)
- Storage limit: ~5-10MB per domain
- No multi-user support (each browser = separate database)
- No real-time synchronization

## Security Notes
- Data stored in browser (client-side only)
- No network requests after page load
- Safe from SQL injection (no SQL used)
- Export files are plain JSON (not encrypted)

## Troubleshooting

**Q: Data disappeared after clearing browser data**  
A: localStorage is cleared with browser data. Use export feature for backups.

**Q: Can't see the application**  
A: Ensure `.htaccess` is uploaded and Apache serves `.html` files.

**Q: Import fails**  
A: Check JSON file format matches export format.

**Q: Storage quota exceeded**  
A: Export data, clear database, remove unnecessary records.

## Perfect For
- Course assignments
- Demonstrations
- Environments with restricted server access
- Quick prototyping
- Learning database concepts

## Not Suitable For
- Production use
- Multi-user environments
- Large datasets
- Secure/sensitive data

---

This static version was created specifically for environments where server-side execution (PHP, Python, CGI) is not available or restricted.