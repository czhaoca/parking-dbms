<?php
// Start session for future login functionality
session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parking Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        .bgimg {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 2rem;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 1.5rem;
            text-align: center;
        }
        
        .header p {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        
        .header hr {
            border: none;
            border-top: 1px solid rgba(255, 255, 255, 0.3);
            margin: 0.5rem 0;
        }
        
        .title {
            background-color: #34495e;
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .title h1 {
            font-size: 2.5rem;
            font-weight: 300;
            letter-spacing: 2px;
        }
        
        .content {
            padding: 2rem;
        }
        
        .section {
            margin-bottom: 2rem;
        }
        
        .section p {
            font-size: 1.2rem;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 1rem;
            border-bottom: 2px solid #3498db;
            padding-bottom: 0.5rem;
        }
        
        .section ul {
            list-style: none;
        }
        
        .section li {
            margin-bottom: 0.8rem;
            padding-left: 1rem;
        }
        
        .section a {
            color: #3498db;
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block;
            padding: 0.3rem 0;
        }
        
        .section a:hover {
            color: #2980b9;
            transform: translateX(5px);
        }
        
        .section a:before {
            content: "▸ ";
            color: #3498db;
            margin-right: 0.5rem;
        }
        
        .version {
            background-color: #ecf0f1;
            padding: 1rem;
            text-align: center;
            color: #7f8c8d;
        }
        
        .version hr {
            border: none;
            border-top: 1px solid #bdc3c7;
            margin: 0.5rem 0;
        }
        
        @media (max-width: 768px) {
            .bgimg {
                padding: 1rem;
            }
            
            .title h1 {
                font-size: 1.8rem;
            }
            
            .content {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
<div class="bgimg">
    <div class="container">
        <div class="header">
          <p>Project Demo version</p>
          <hr>
        </div>

        <div class="title">
            <h1>Parking Management System</h1>
        </div>

        <div class="content">
            <div class="section main">
                <p>Report Generation</p>
                <ul>
                    <li><a href="employeeStatusReport.php">Generate PT/FT Employee List</a></li>
                    <li><a href="displayEmployee.php">Display Employee List</a></li>
                    <li><a href="displayWaitList.php">Display Wait List</a></li>
                    <li><a href="displayYoung.php">Display Youngest Employee</a></li>
                    <li><a href="displayWaitListEmployee.php">Display Employees Still in Wait List</a></li>
                </ul>
            </div>

            <div class="section utils">
                <p>Database Maintenance</p>
                <ul>
                    <li><a href="utils/loginInfo.php">Login Info Table Maintenance</a></li>
                    <li><a href="utils/buildingInfo.php">Building Info Table Maintenance</a></li>
                    <li><a href="utils/departmentInfo.php">Department Info Table Maintenance</a></li>
                    <li><a href="utils/employeeInfo.php">Employee Info Table Maintenance</a></li>
                    <li><a href="utils/evBook.php">EV Booking Info Table Maintenance</a></li>
                    <li><a href="utils/parkingInfo.php">Parking Info Table Maintenance</a></li>
                    <li><a href="utils/parkingWaitList.php">Parking Waitlist Info Table Maintenance</a></li>
                </ul>
            </div>

            <div class="section doc">
                <p>Project Information</p>
                <ul>
                    <li><a href="README.md">Project Documentation</a></li>
                    <li><a href="https://github.com/czhaoca/parking-dbms" target="_blank">GitHub Repository</a></li>
                </ul>
            </div>
        </div>

        <div class="version">
            <hr>
            <p>Version 2.0 - <?php echo date('M d, Y'); ?> | Migrated to OCI Free Tier</p>
        </div>
    </div>
</div>
</body>
</html>