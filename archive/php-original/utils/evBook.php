  <html>
    <head>
        <title>EVBooking Table Maintenance Page</title>
    </head>

    <body>
        <a href="../index.php">Back to Main Page</a><br>
        <hr/>    
        <h2>Insert Values into evBook</h2>
        <form method="POST" action="evBook.php"> <!--refresh page when submitted-->
            <input type="hidden" id="insertQueryRequest" name="insertQueryRequest">
            BookingID: <input type="text" name="insID"> <br /><br />
            ParkingNum: <input type="text" name="insNum"> <br /><br />
            EmployeeID: <input type="text" name="insEmployeeID"> <br /><br />
            BookingDate: <input type="text" name="insDate"> <br /><br />
            StartTime: <input type="text" name="insStartTime"> <br /><br />

            <input type="submit" value="Insert" name="insertSubmit"></p>
        </form>

        <hr />

        <h2>Update Name in evBook</h2>
        <p>The values are case sensitive and if you enter in the wrong case, the update statement will not do anything.</p>

        <form method="POST" action="evBook.php"> <!--refresh page when submitted-->
            <input type="hidden" id="updateQueryRequest" name="updateQueryRequest">
            Booking ID: <input type="text" name="bookingId"> <br /><br />
            New Booking Date: <input type="text" name="newBookingDate"> <br /><br />

            <input type="submit" value="Update" name="updateSubmit"></p>
        </form>

        <hr />

        <h2>Count the Tuples in evBook</h2>
        <form method="GET" action="evBook.php"> <!--refresh page when submitted-->
            <input type="hidden" id="countTupleRequest" name="countTupleRequest">
            <input type="submit" name="countTuples"></p>
        </form>

        <hr />


        <h2>Display the Tuples in evBook</h2>
        <form method="GET" action="evBook.php"> <!--refresh page when submitted-->
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
            echo "<br>Retrieved data from table evBook:<br>";
            echo "<table>";
            echo "<tr><th>Book ID (PK) | </th><th>Parking Num |  </th><th>Employee ID |  </th><th>Booking Date |
            </th><th> Start Time</th></tr>";

            while ($row = OCI_Fetch_Array($result, OCI_BOTH)) {
                echo "<tr><td>" . $row["BOOKID"] . "</td><td>" . $row["PARKINGNUM"] . "</td><td>" . $row["EMPLOYEEID"] .
                "</td><td>" . $row["BOOKINGDATE"] . "</td><td>" . $row["STARTTIME"] . "</td></tr>"; //or just use "echo $row[0]"
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

            $book_id = $_POST['bookingId'];
            $new_name = $_POST['newBookingDate'];

            // you need the wrap the old name and new name values with single quotations
            executePlainSQL("UPDATE evBook SET bookingDate='" . $new_name . "' WHERE bookID='" . $book_id . "'");
            OCICommit($db_conn);
        }

        function handleResetRequest() {
            global $db_conn;
            // Drop old table
            executePlainSQL("DROP TABLE evBook");

            // Create new table
            echo "<br> creating new table <br>";
            executePlainSQL("CREATE TABLE evBook 
            (bookId int primary key, 
              parkingNum int,
              employeeId int,
              bookingDate date, 
              startTime int
              )");
            OCICommit($db_conn);
        }

        function handleInsertRequest() {
            global $db_conn;

            //Getting the values from user and insert data into the table
            $tuple = array (
                ":bind1" => $_POST['insID'],
                ":bind2" => $_POST['insNum'],
                ":bind3" => $_POST['insEmployeeID'], 
                ":bind4" => $_POST['insDate'], 
                ":bind5" => $_POST['insStartTime']
            );

            $alltuples = array (
                $tuple
            );

            executeBoundSQL("insert into evBook values (:bind1, :bind2, :bind3, :bind4, :bind5)", $alltuples);
            OCICommit($db_conn);
        }

        function handleCountRequest() {
            global $db_conn;

            $result = executePlainSQL("SELECT Count(*) FROM evBook");

            if (($row = oci_fetch_row($result)) != false) {
                echo "<br> The number of tuples in evBook: " . $row[0] . "<br>";
            }
        }

        function handlePrintRequest() {
            global $db_conn;

            $result = executePlainSQL("SELECT * FROM evBook");

            if (($row = oci_fetch_row($result)) != false) {
                printResult($result);
            }
        }


    // HANDLE ALL POST ROUTES
	// A better coding practice is to have one method that reroutes your requests accordingly. It will make it easier to add/remove functionality.
        function handlePOSTRequest() {
            if (connectToDB()) {
                if (array_key_exists('resetTablesRequest', $_POST)) {
                    handleResetRequest();
                } else if (array_key_exists('updateQueryRequest', $_POST)) {
                    handleUpdateRequest();
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

		if (isset($_POST['reset']) || isset($_POST['updateSubmit']) || isset($_POST['insertSubmit'])) {
            handlePOSTRequest();
        } else if (isset($_GET['countTupleRequest']) ||
                   isset($_GET['printResultRequest'])) {
            handleGETRequest();
        }
		?>
	</body>
</html>