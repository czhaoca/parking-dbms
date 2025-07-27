#!/bin/bash
# Test various options for interactive functionality on school server

echo "Testing Interactive Web Options"
echo "==============================="
echo ""

# Create test directory
mkdir -p interactive-tests
cd interactive-tests

# Test 1: Client-side SQLite with sql.js
echo "1. Creating client-side SQLite test..."
cat > sqlite-browser-test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>SQLite in Browser Test</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/sql-wasm.js"></script>
    <style>
        body { font-family: Arial; margin: 20px; }
        .section { margin: 20px 0; padding: 10px; border: 1px solid #ccc; }
        button { margin: 5px; padding: 5px 10px; }
        #output { background: #f0f0f0; padding: 10px; margin-top: 10px; }
    </style>
</head>
<body>
    <h1>SQLite in Browser Test</h1>
    
    <div class="section">
        <h2>Initialize Database</h2>
        <button onclick="initDB()">Create Database</button>
        <button onclick="loadSampleData()">Load Sample Data</button>
    </div>
    
    <div class="section">
        <h2>Query Database</h2>
        <textarea id="query" rows="4" cols="50">SELECT * FROM employeeInfo;</textarea><br>
        <button onclick="runQuery()">Run Query</button>
    </div>
    
    <div class="section">
        <h2>CRUD Operations</h2>
        <button onclick="addEmployee()">Add Employee</button>
        <button onclick="updateEmployee()">Update Employee</button>
        <button onclick="deleteEmployee()">Delete Employee</button>
    </div>
    
    <div id="output"></div>

    <script>
        let db = null;
        
        async function initDB() {
            const sqlPromise = initSqlJs({
                locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`
            });
            const SQL = await sqlPromise;
            db = new SQL.Database();
            
            // Create tables
            db.run(`
                CREATE TABLE employeeInfo (
                    employeeId INTEGER PRIMARY KEY,
                    firstName TEXT NOT NULL,
                    lastName TEXT NOT NULL,
                    employeeStatus TEXT NOT NULL,
                    departmentId INTEGER NOT NULL,
                    age INTEGER NOT NULL
                );
            `);
            
            document.getElementById('output').innerHTML = 'Database initialized!';
        }
        
        function loadSampleData() {
            if (!db) { alert('Initialize database first!'); return; }
            
            db.run(`
                INSERT INTO employeeInfo VALUES 
                (1, 'John', 'Doe', 'FT', 1, 30),
                (2, 'Jane', 'Smith', 'PT', 2, 25),
                (3, 'Bob', 'Johnson', 'FT', 1, 35);
            `);
            
            document.getElementById('output').innerHTML = 'Sample data loaded!';
        }
        
        function runQuery() {
            if (!db) { alert('Initialize database first!'); return; }
            
            const query = document.getElementById('query').value;
            try {
                const result = db.exec(query);
                let html = '<h3>Results:</h3>';
                
                if (result.length > 0) {
                    html += '<table border="1"><tr>';
                    result[0].columns.forEach(col => html += '<th>' + col + '</th>');
                    html += '</tr>';
                    result[0].values.forEach(row => {
                        html += '<tr>';
                        row.forEach(val => html += '<td>' + val + '</td>');
                        html += '</tr>';
                    });
                    html += '</table>';
                } else {
                    html += 'Query executed successfully (no results)';
                }
                
                document.getElementById('output').innerHTML = html;
            } catch (e) {
                document.getElementById('output').innerHTML = 'Error: ' + e.message;
            }
        }
        
        function addEmployee() {
            const name = prompt('Enter first name:');
            if (name) {
                db.run(`INSERT INTO employeeInfo VALUES (?, ?, 'NewLast', 'FT', 1, 25)`, 
                    [Date.now(), name]);
                runQuery();
            }
        }
        
        function updateEmployee() {
            const id = prompt('Enter employee ID to update:');
            const newName = prompt('Enter new first name:');
            if (id && newName) {
                db.run(`UPDATE employeeInfo SET firstName = ? WHERE employeeId = ?`, 
                    [newName, id]);
                runQuery();
            }
        }
        
        function deleteEmployee() {
            const id = prompt('Enter employee ID to delete:');
            if (id) {
                db.run(`DELETE FROM employeeInfo WHERE employeeId = ?`, [id]);
                runQuery();
            }
        }
    </script>
</body>
</html>
EOF

# Test 2: IndexedDB for persistence
echo "2. Creating IndexedDB test..."
cat > indexeddb-test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>IndexedDB CRUD Test</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .form-group { margin: 10px 0; }
        label { display: inline-block; width: 120px; }
        input { width: 200px; padding: 5px; }
        button { margin: 5px; padding: 5px 15px; }
        #employeeList { margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>IndexedDB CRUD Demo</h1>
    
    <div>
        <h2>Add Employee</h2>
        <div class="form-group">
            <label>First Name:</label>
            <input type="text" id="firstName">
        </div>
        <div class="form-group">
            <label>Last Name:</label>
            <input type="text" id="lastName">
        </div>
        <div class="form-group">
            <label>Age:</label>
            <input type="number" id="age">
        </div>
        <button onclick="addEmployee()">Add Employee</button>
    </div>
    
    <div id="employeeList"></div>

    <script>
        let db;
        
        // Initialize IndexedDB
        const request = indexedDB.open('ParkingDB', 1);
        
        request.onerror = () => console.error('Database failed to open');
        
        request.onsuccess = () => {
            db = request.result;
            displayEmployees();
        };
        
        request.onupgradeneeded = (e) => {
            db = e.target.result;
            
            if (!db.objectStoreNames.contains('employees')) {
                const objectStore = db.createObjectStore('employees', 
                    { keyPath: 'id', autoIncrement: true });
                objectStore.createIndex('lastName', 'lastName', { unique: false });
            }
        };
        
        function addEmployee() {
            const employee = {
                firstName: document.getElementById('firstName').value,
                lastName: document.getElementById('lastName').value,
                age: parseInt(document.getElementById('age').value),
                timestamp: new Date()
            };
            
            const transaction = db.transaction(['employees'], 'readwrite');
            const objectStore = transaction.objectStore('employees');
            objectStore.add(employee);
            
            transaction.oncomplete = () => {
                document.getElementById('firstName').value = '';
                document.getElementById('lastName').value = '';
                document.getElementById('age').value = '';
                displayEmployees();
            };
        }
        
        function deleteEmployee(id) {
            const transaction = db.transaction(['employees'], 'readwrite');
            const objectStore = transaction.objectStore('employees');
            objectStore.delete(id);
            
            transaction.oncomplete = () => displayEmployees();
        }
        
        function displayEmployees() {
            const objectStore = db.transaction('employees').objectStore('employees');
            let html = '<h2>Employee List</h2><table><tr><th>ID</th><th>First Name</th><th>Last Name</th><th>Age</th><th>Actions</th></tr>';
            
            objectStore.openCursor().onsuccess = (e) => {
                const cursor = e.target.result;
                
                if (cursor) {
                    html += `<tr>
                        <td>${cursor.value.id}</td>
                        <td>${cursor.value.firstName}</td>
                        <td>${cursor.value.lastName}</td>
                        <td>${cursor.value.age}</td>
                        <td><button onclick="deleteEmployee(${cursor.value.id})">Delete</button></td>
                    </tr>`;
                    cursor.continue();
                } else {
                    html += '</table>';
                    document.getElementById('employeeList').innerHTML = html;
                }
            };
        }
    </script>
</body>
</html>
EOF

# Test 3: Simple AJAX-style interface with JSON
echo "3. Creating AJAX-style test..."
cat > ajax-test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AJAX-Style Interface</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .endpoint { margin: 10px 0; padding: 10px; background: #f0f0f0; }
        button { margin: 5px; }
        #response { margin-top: 20px; padding: 10px; background: #e0e0e0; }
    </style>
</head>
<body>
    <h1>AJAX-Style Interface Test</h1>
    
    <div class="endpoint">
        <h3>Test Static JSON Loading</h3>
        <button onclick="loadStaticData()">Load Employee Data</button>
    </div>
    
    <div class="endpoint">
        <h3>Test Local Storage CRUD</h3>
        <button onclick="saveToLocal()">Save Data</button>
        <button onclick="loadFromLocal()">Load Data</button>
        <button onclick="clearLocal()">Clear Data</button>
    </div>
    
    <div id="response"></div>

    <script>
        // Create a static JSON file for testing
        const sampleData = {
            employees: [
                {id: 1, name: "John Doe", dept: "IT"},
                {id: 2, name: "Jane Smith", dept: "HR"},
                {id: 3, name: "Bob Johnson", dept: "Sales"}
            ]
        };
        
        function loadStaticData() {
            // Simulate loading from a static JSON file
            document.getElementById('response').innerHTML = 
                '<pre>' + JSON.stringify(sampleData, null, 2) + '</pre>';
        }
        
        function saveToLocal() {
            localStorage.setItem('parkingData', JSON.stringify(sampleData));
            document.getElementById('response').innerHTML = 'Data saved to LocalStorage';
        }
        
        function loadFromLocal() {
            const data = localStorage.getItem('parkingData');
            if (data) {
                document.getElementById('response').innerHTML = 
                    '<pre>' + JSON.parse(data) + '</pre>';
            } else {
                document.getElementById('response').innerHTML = 'No data in LocalStorage';
            }
        }
        
        function clearLocal() {
            localStorage.clear();
            document.getElementById('response').innerHTML = 'LocalStorage cleared';
        }
    </script>
</body>
</html>
EOF

# Create sample data file
cat > employees.json << 'EOF'
{
    "employees": [
        {"id": 1, "firstName": "John", "lastName": "Doe", "status": "FT", "age": 30},
        {"id": 2, "firstName": "Jane", "lastName": "Smith", "status": "PT", "age": 25},
        {"id": 3, "firstName": "Bob", "lastName": "Johnson", "status": "FT", "age": 35}
    ],
    "departments": [
        {"id": 1, "name": "IT", "building": 1},
        {"id": 2, "name": "HR", "building": 2},
        {"id": 3, "name": "Sales", "building": 1}
    ]
}
EOF

# Create index file
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Interactive Options Test</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .test-link { 
            display: block; 
            margin: 10px 0; 
            padding: 10px; 
            background: #f0f0f0; 
            text-decoration: none; 
            color: #333;
        }
        .test-link:hover { background: #e0e0e0; }
    </style>
</head>
<body>
    <h1>Interactive Functionality Tests</h1>
    <p>Test these options to see what works on the school server:</p>
    
    <a href="sqlite-browser-test.html" class="test-link">
        <strong>1. SQLite in Browser (sql.js)</strong><br>
        Full SQLite database running in the browser with CRUD operations
    </a>
    
    <a href="indexeddb-test.html" class="test-link">
        <strong>2. IndexedDB Storage</strong><br>
        Browser-native database with persistence across sessions
    </a>
    
    <a href="ajax-test.html" class="test-link">
        <strong>3. AJAX-Style Interface</strong><br>
        Loading static JSON files and using LocalStorage
    </a>
    
    <a href="../cgi-test/test.py" class="test-link">
        <strong>4. Python CGI Test</strong><br>
        Test if Python CGI scripts work (may require Apache config)
    </a>
    
    <a href="../cgi-test/test.sh" class="test-link">
        <strong>5. Shell CGI Test</strong><br>
        Test if Shell CGI scripts work (may require Apache config)
    </a>
    
    <h2>Next Steps</h2>
    <ol>
        <li>Run analyze-school-server.sh to check server capabilities</li>
        <li>Test each option above</li>
        <li>Report back which options work</li>
        <li>We'll build the solution using the working approach</li>
    </ol>
</body>
</html>
EOF

cd ..

echo ""
echo "Test files created in interactive-tests/"
echo "After running on school server, report which options work!"