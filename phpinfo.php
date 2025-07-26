<?php
// Simple PHP test file
echo "<h1>PHP is working!</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";

// Check for OCI8 extension
if (function_exists('oci_connect')) {
    echo "<p style='color: green;'>✓ OCI8 extension is installed</p>";
} else {
    echo "<p style='color: red;'>✗ OCI8 extension is NOT installed</p>";
}

// Display PHP info (comment out in production)
phpinfo();
?>