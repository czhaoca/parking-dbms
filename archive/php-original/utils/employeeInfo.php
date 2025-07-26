  <html>
    <head>
        <title>Employee Table Maintenance Page</title>
    </head>

    <body>
        <a href="../index.php">Back to Main Page</a><br>
        <hr/>

        <h2>Insert Values into employeeInfo</h2>
        <form method="POST" action="employeeInfo.php"> <!--refresh page when submitted-->
            <input type="hidden" id="insertQueryRequest" name="insertQueryRequest">
            EmployeeId: <input type="text" name="insEmployeeId"> <br /><br />
            FirstName: <input type="text" name="insFirstName"> <br /><br />
            LastName: <input type="text" name="insLastName"> <br /><br />
            EmployeeStatus: <input type="text" name="insEmployeeStatus"> <br /><br />
            DepartmentId: <input type="text" name="insDepartmentId"> <br /><br />
            Age: <input type="text" name="insAge"> <br /><br />

            <input type="submit" value="Insert" name="insertSubmit"></p>
        </form>

        <hr />

        <h2>Update employee Status in employeeInfo</h2>
        <p>The values are case sensitive and if you enter in the wrong case, the update statement will not do anything.</p>

        <form method="POST" action="employeeInfo.php"> <!--refresh page when submitted-->
            <input type="hidden" id="updateQueryRequest" name="updateQueryRequest">
            Employee ID: <input type="text" name="employeeId"> <br /><br />
            New employeeStatus: <input type="text" name="newEmployeeStatus"> <br /><br />

            <input type="submit" value="Update" name="updateSubmit"></p>
        </form>

        <hr/>

        <h2>Delete Employee in employeeInfo</h2>
        <p>If the value you enter in the wrong case, the delete statement will not do anything.</p>

        <form method="POST" action="employeeInfo.php"> <!--refresh page when submitted-->
            <input type="hidden" id="deleteQueryRequest" name="deleteQueryRequest">
            Employee ID: <input type="text" name="employeeId"> <br /><br />

            <input type="submit" value="Delete" name="deleteSubmit"></p>
        </form>

        <hr/>

        <h2>Count the Tuples in employeeInfo</h2>
        <form method="GET" action="employeeInfo.php"> <!--refresh page when submitted-->
            <input type="hidden" id="countTupleRequest" name="countTupleRequest">
            <input type="submit" name="countTuples"></p>
        </form>

        <hr />


        <h2>Display the Tuples in employeeInfo</h2>
        <form method="GET" action="employeeInfo.php"> <!--refresh page when submitted-->
            <input type="hidden" id="printResultRequest" name="printResultRequest">
            <input type="submit" name="printResult"></p>
        </form>

        <?php
		//this tells the system that it's no longer just parsing html; it's now parsing PHP

        $success = True; //keep track of errors so it redirects the page only if there are no errors
        $db_conn = NULL; // edit the login credentials in connectToDB()
        $show_debug_alert_messages = False; // set to True if you want alerts to show you which methods are being triggered (see how it is used in debugAlertMessage())

        function debugAlertMessage($message) {
            global $show_debug_alert_messages;

            if ($show_debug_alert_messages) {
                echo "<script type='text/javascript'>alert('" . $message . "');</script>";
            }
        }

        function executePlainSQL($cmdstr) { //takes a plain (no bound variables) SQL command and executes it
            //echo "<br>running ".$cmdstr."<br>";
            global $db_conn, $success;

            $statement = OCIParse($db_conn, $cmdstr);
            //There are a set of comments at the end of the file that describe some of the OCI specific functions and how they work

            if (!$statement) {
                echo "<br>Cannot parse the following command: " . $cmdstr . "<br>";
                $e = OCI_Error($db_conn); // For OCIParse errors pass the connection handle
                echo htmlentities($e['message']);
                $success = False;
            }

            $r = OCIExecute($statement, OCI_DEFAULT);
            if (!$r) {
                echo "<br>Cannot execute the following command: " . $cmdstr . "<br>";
                $e = oci_error($statement); // For OCIExecute errors pass the statementhandle
                echo htmlentities($e['message']);
                $success = False;
            }

			return $statement;
		}

        function executeBoundSQL($cmdstr, $list) {
            /* Sometimes the same statement will be executed several times with different values for the variables involved in the query.
		In this case you don't need to create the statement several times. Bound variables cause a statement to only be
		parsed once and you can reuse the statement. This is also very useful in protecting against SQL injection.
		See the sample code below for how this function is used */

			global $db_conn, $success;
			$statement = OCIParse($db_conn, $cmdstr);

            if (!$statement) {
                echo "<br>Cannot parse the following command: " . $cmdstr . "<br>";
                $e = OCI_Error($db_conn);
                echo htmlentities($e['message']);
                $success = False;
            }

            foreach ($list as $tuple) {
                foreach ($tuple as $bind => $val) {
                    //echo $val;
                    //echo "<br>".$bind."<br>";
                    OCIBindByName($statement, $bind, $val);
                    unset ($val); //make sure you do not remove this. Otherwise $val will remain in an array object wrapper which will not be recognized by Oracle as a proper datatype
				}

                $r = OCIExecute($statement, OCI_DEFAULT);
                if (!$r) {
                    echo "<br>Cannot execute the following command: " . $cmdstr . "<br>";
                    $e = OCI_Error($statement); // For OCIExecute errors, pass the statementhandle
                    echo htmlentities($e['message']);
                    echo "<br>";
                    $success = False;
                }
            }
        }

        function printResult($result) { //prints results from a select statement
            echo "<br>Retrieved data from table employeeInfo:<br>";
            echo "<table>";
            echo "<tr><th>Employee ID (PK) | </th><th>First Name | </th><th>Last Name |  </th><th>Employee Status |  </th><th>Department ID | </th><th>Age</th></tr>";

            while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                echo "<tr><td>" . $row["EMPLOYEEID"] . "</td><td>" . $row["FIRSTNAME"] . "</td><td>" . $row["LASTNAME"] .  "</td><td>" . $row["EMPLOYEESTATUS"] .  "</td><td>" . $row["DEPARTMENTID"] . 
                "</td><td>" . $row["AGE"] ."</td></tr>"; //or just use "echo $row[0]"
            }

            echo "</table>";
        }

        function connectToDB() {
            global $db_conn;

            // Your username is ora_(CWL_ID) and the password is a(student number). For example,
			// ora_platypus is the username and a12345678 is the password.
            // $oraUserName = "ora_chris019";
            // $oraPW = "a23166184";
            $oraUserName = "ora_czha";
            $oraPW = "a45834132";
            $oraServer = "dbhost.students.cs.ubc.ca:1522/stu";

            $db_conn = OCILogon($oraUserName, $oraPW, $oraServer);

            if ($db_conn) {
                debugAlertMessage("Database is Connected");
                return true;
            } else {
                debugAlertMessage("Cannot connect to Database");
                $e = OCI_Error(); // For OCILogon errors pass no handle
                echo htmlentities($e['message']);
                return false;
            }
        }

        function disconnectFromDB() {
            global $db_conn;

            debugAlertMessage("Disconnect from Database");
            OCILogoff($db_conn);
        }

        function handleUpdateRequest() {
            global $db_conn;

            $employee_id = $_POST['employeeId'];
            $new_employeeStatus = $_POST['newEmployeeStatus'];

            // you need the wrap the old name and new name values with single quotations
            executePlainSQL("UPDATE employeeInfo SET employeeStatus='" . $new_employeeStatus . "' WHERE employeeId='" . $employee_id . "'");
            OCICommit($db_conn);
        }

        function handleDeleteRequest() {
            global $db_conn;

            $employee_id = $_POST['employeeId'];

            // you need the wrap the old name and new name values with single quotations
            executePlainSQL("DELETE from employeeInfo WHERE employeeId='" . $employee_id . "'");
            OCICommit($db_conn);
        }

        function handleResetRequest() {
            global $db_conn;
            // Drop old table
            executePlainSQL("DROP TABLE employeeInfo");

            // Create new table
            echo "<br> creating new table <br>";
            executePlainSQL("CREATE TABLE employeeInfo 
            (employeeId int primary key, 
            firstName char(30), 
            lastName char(30), 
            employeeStatus char(2), 
            departmentId int, 
            age int,
            foreign key departmentId references departmentInfo)");
            OCICommit($db_conn);
        }

        function handleInsertRequest() {
            global $db_conn;

            //Getting the values from user and insert data into the table
            $tuple = array (
                ":bind1" => $_POST['insEmployeeId'],
                ":bind2" => $_POST['insFirstName'],
                ":bind3" => $_POST['insLastName'], 
                ":bind4" => $_POST['insEmployeeStatus'], 
                ":bind5" => $_POST['insDepartmentId'],
                ":bind6" => $_POST['insAge']
            );

            $alltuples = array (
                $tuple
            );

            executeBoundSQL("insert into employeeInfo values (:bind1, :bind2, :bind3, :bind4, :bind5, :bind6)", $alltuples);
            OCICommit($db_conn);
        }

        function handleCountRequest() {
            global $db_conn;

            $result = executePlainSQL("SELECT Count(*) FROM employeeInfo");

            if (($row = oci_fetch_row($result)) != false) {
                echo "<br> The number of tuples in employeeInfo: " . $row[0] . "<br>";
            }
        }

        function handlePrintRequest() {
            global $db_conn;

            $result = executePlainSQL("SELECT * FROM employeeInfo");
                printResult($result);

        }


    // HANDLE ALL POST ROUTES
	// A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handlePOSTRequest() {
            if (connectToDB()) {
                if (array_key_exists('resetTablesRequest', $_POST)) {
                    handleResetRequest();
                } else if (array_key_exists('updateQueryRequest', $_POST)) {
                    handleUpdateRequest();
                } else if (array_key_exists('deleteQueryRequest', $_POST)) {
                    handleDeleteRequest();
                } else if (array_key_exists('insertQueryRequest', $_POST)) {
                    handleInsertRequest();
                }

                disconnectFromDB();
            }
        }

        // HANDLE ALL GET ROUTES
	// A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handleGETRequest() {
            if (connectToDB()) {
                if (array_key_exists('countTuples', $_GET)) {
                    handleCountRequest();
                }
                else if (array_key_exists('printResult', $_GET)) {
                    handlePrintRequest();
                }

                disconnectFromDB();
            }
        }

		if (isset($_POST['reset']) || isset($_POST['updateSubmit']) 
        || isset($_POST['deleteSubmit']) || isset($_POST['insertSubmit'])) {
            handlePOSTRequest();
        } else if (isset($_GET['countTupleRequest']) || 
                     isset($_GET['printResultRequest'])) {
            handleGETRequest();
        }
		?>
	</body>
</html>