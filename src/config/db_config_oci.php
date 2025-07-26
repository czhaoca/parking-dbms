<?php
/**
 * Oracle Autonomous Database Configuration for OCI Free Tier
 * 
 * This configuration file is for connecting to Oracle Autonomous Database
 * in Oracle Cloud Infrastructure (OCI) Free Tier.
 * 
 * Prerequisites:
 * 1. Download wallet file from OCI Console
 * 2. Extract wallet to a secure directory
 * 3. Install Oracle Instant Client
 * 4. Set TNS_ADMIN environment variable to wallet directory
 * 5. Set database credentials in environment variables or .env file
 */

// Load environment variables from .env file if it exists
$envFile = dirname(__DIR__, 2) . '/.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);
        if (!empty($name) && !isset($_ENV[$name])) {
            putenv("$name=$value");
            $_ENV[$name] = $value;
        }
    }
}

// Database connection parameters from environment variables
define('DB_TNS_NAME', getenv('DB_TNS_NAME') ?: 'your_db_name_high');
define('DB_USERNAME', getenv('DB_USERNAME') ?: 'PARKING_APP');
define('DB_PASSWORD', getenv('DB_PASSWORD') ?: die('Database password not set in environment'));

// Optional configuration with defaults
define('DB_CHARSET', getenv('DB_CHARSET') ?: 'AL32UTF8');
define('DB_SESSION_MODE', OCI_DEFAULT);

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

/**
 * Create database connection
 * @return resource|false OCI connection resource or false on failure
 */
function connectToDatabase() {
    try {
        // For Autonomous Database, use the TNS alias from the wallet
        $connection = oci_connect(
            DB_USERNAME,
            DB_PASSWORD,
            DB_TNS_NAME,
            DB_CHARSET,
            DB_SESSION_MODE
        );
        
        if (!$connection) {
            $error = oci_error();
            error_log("Database connection failed: " . $error['message']);
            return false;
        }
        
        // Set session parameters for better performance
        $stmtArray = array(
            "ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD'",
            "ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'",
            "ALTER SESSION SET TIME_ZONE = 'America/Vancouver'" // Adjust as needed
        );
        
        foreach ($stmtArray as $sql) {
            $stmt = oci_parse($connection, $sql);
            oci_execute($stmt);
            oci_free_statement($stmt);
        }
        
        return $connection;
    } catch (Exception $e) {
        error_log("Database connection exception: " . $e->getMessage());
        return false;
    }
}

/**
 * Close database connection
 * @param resource $connection OCI connection resource
 */
function closeConnection($connection) {
    if ($connection) {
        oci_close($connection);
    }
}

/**
 * Execute a SELECT query and return results
 * @param string $sql SQL query
 * @param array $params Parameters for bind variables
 * @return array|false Query results or false on failure
 */
function executeQuery($sql, $params = array()) {
    $connection = connectToDatabase();
    if (!$connection) {
        return false;
    }
    
    $stmt = oci_parse($connection, $sql);
    if (!$stmt) {
        $error = oci_error($connection);
        error_log("Parse error: " . $error['message']);
        closeConnection($connection);
        return false;
    }
    
    // Bind parameters if provided
    foreach ($params as $key => $value) {
        oci_bind_by_name($stmt, $key, $params[$key]);
    }
    
    $result = oci_execute($stmt);
    if (!$result) {
        $error = oci_error($stmt);
        error_log("Execute error: " . $error['message']);
        oci_free_statement($stmt);
        closeConnection($connection);
        return false;
    }
    
    $data = array();
    while (($row = oci_fetch_assoc($stmt)) != false) {
        $data[] = $row;
    }
    
    oci_free_statement($stmt);
    closeConnection($connection);
    
    return $data;
}

/**
 * Execute an INSERT, UPDATE, or DELETE statement
 * @param string $sql SQL statement
 * @param array $params Parameters for bind variables
 * @return bool True on success, false on failure
 */
function executeStatement($sql, $params = array()) {
    $connection = connectToDatabase();
    if (!$connection) {
        return false;
    }
    
    $stmt = oci_parse($connection, $sql);
    if (!$stmt) {
        $error = oci_error($connection);
        error_log("Parse error: " . $error['message']);
        closeConnection($connection);
        return false;
    }
    
    // Bind parameters if provided
    foreach ($params as $key => $value) {
        oci_bind_by_name($stmt, $key, $params[$key]);
    }
    
    $result = oci_execute($stmt, OCI_NO_AUTO_COMMIT);
    if (!$result) {
        $error = oci_error($stmt);
        error_log("Execute error: " . $error['message']);
        oci_free_statement($stmt);
        closeConnection($connection);
        return false;
    }
    
    // Commit the transaction
    $commit = oci_commit($connection);
    if (!$commit) {
        $error = oci_error($connection);
        error_log("Commit error: " . $error['message']);
        oci_rollback($connection);
        oci_free_statement($stmt);
        closeConnection($connection);
        return false;
    }
    
    oci_free_statement($stmt);
    closeConnection($connection);
    
    return true;
}

/**
 * Get the last error message
 * @return string Error message
 */
function getLastError() {
    $error = oci_error();
    return $error ? $error['message'] : 'Unknown error';
}

// Test connection on include (comment out in production)
// $testConn = connectToDatabase();
// if ($testConn) {
//     echo "Database connection successful!\n";
//     closeConnection($testConn);
// } else {
//     echo "Database connection failed: " . getLastError() . "\n";
// }
?>