<?php
// Test file to verify PHP works without .htaccess
echo "<!DOCTYPE html>";
echo "<html><head><title>PHP Test</title></head><body>";
echo "<h1>PHP Test Without .htaccess</h1>";
echo "<p>If you see this message, PHP is working but .htaccess might be the issue.</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";

// Test if we can include the config file
$configFile = __DIR__ . '/src/config/db_config_oci.php';
if (file_exists($configFile)) {
    echo "<p style='color: green;'>✓ Config file exists at: $configFile</p>";
} else {
    echo "<p style='color: red;'>✗ Config file NOT found at: $configFile</p>";
}

echo "<hr>";
echo "<h2>Debugging Steps:</h2>";
echo "<ol>";
echo "<li>First, rename .htaccess to .htaccess.bak: <code>mv .htaccess .htaccess.bak</code></li>";
echo "<li>Try accessing this file and index.php again</li>";
echo "<li>If PHP works after removing .htaccess, the issue is with .htaccess directives</li>";
echo "<li>If PHP still doesn't work, contact your system administrator</li>";
echo "</ol>";
echo "</body></html>";
?>