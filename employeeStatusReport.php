<html>
    <head>
        <title>Employee Status Report</title>
    </head>

    <body>
        <a href="index.php">Back to Main Page</a><br>

        <hr />

        <h2>Display employee Status in employeeInfo</h2>
        <p>The values are case sensitive and if you enter in the wrong case, the update statement will not do anything.</p>

        <form method="POST" action="employeeStatusReport.php"> <!--refresh page when submitted-->
            <input type="hidden" id="displayQueryRequest" name="displayQueryRequest">
            EmployeeStatus: <input type="text" name="employeeStatus"> <br /><br/>

            <input type="submit" value="Display" name="displaySubmit"></p>
        </form>

        <hr/>

        <h2>Count Tuples with Employee Status</h2>
        <p>If the value you enter in the wrong case, the delete statement will not do anything.</p>

        <form method="POST" action="employeeStatusReport.php"> <!--refresh page when submitted-->
            <input type="hidden" id="countQueryRequest" name="countQueryRequest">
            EmployeeStatus: <input type="text" name="employeeStatus"> <br /><br/>

            <input type="submit" value="Count" name="countSubmit"></p>
        </form>

        <hr/>

       
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
            echo "<tr><th>Employee ID (PK) | </th><th>First Name | </th><th>Last Name |  </th><th>Employee Status | </th><th>Department ID | </th><th> Age</th></tr>";

            while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                echo "<tr><td>" . $row["EMPLOYEEID"] . "</td><td>" . $row["FIRSTNAME"] . "</td><td>" . $row["LASTNAME"] .  "</td><td>" . $row["EMPLOYEESTATUS"] . 
                "</td><td>" . $row["DEPARTMENTID"] . 
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

            $employeeStatus = $_POST['employeeStatus'];

            // you need the wrap the old name and new name values with single quotations
            $result = executePlainSQL("select * from employeeInfo where employeeStatus='" . $employeeStatus . "'");

            OCICommit($db_conn);
            printResult($result);
        }

        function handleDeleteRequest() {
            global $db_conn;

            $employeeStatus = $_POST['employeeStatus'];

            $result = executePlainSQL("SELECT Count(employeeId) FROM employeeInfo where employeeStatus='" . $employeeStatus . "'");

            if (($row = oci_fetch_row($result)) != false) {
                echo "<br> The number of tuples in employeeInfo: " . $row[0] . "<br>";
            }
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
                } else if (array_key_exists('displayQueryRequest', $_POST)) {
                    handleUpdateRequest();
                } else if (array_key_exists('countQueryRequest', $_POST)) {
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

		if (isset($_POST['reset']) || isset($_POST['displaySubmit']) 
        || isset($_POST['countSubmit']) || isset($_POST['insertSubmit'])) {
            handlePOSTRequest();
        } else if (isset($_GET['countTupleRequest']) || 
                     isset($_GET['printResultRequest'])) {
            handleGETRequest();
        }
		?>
	</body>
</html>