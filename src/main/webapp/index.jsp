<html>
<body>

<h2>OWSX RESTful Web Service</h2>

<h4>RESTful Adapter that calls <code>ORAWSV</code> SOAP web service</h4>
<ol>
    <li>Use Spring <code>DispatchServlet</code> to accept simple RESTful GET request.</li>
    <li>Handler delegates to a SOAP client, which makes SOAP call to <code>orawsv/OWSX/OWSX_UTL/PAY_RAISE</code>.</li>
</ol>

<form action="service/getPayRaise" method="GET" accept-charset="UTF-8">
<fieldset>
<legend>Test <code>orawsv/OWSX/OWSX_UTL/PAY_RAISE</code></legend>
<table>
 <tr><td>Current Salary:</td><td><input type="number" name="currentSalary" required="true" value="75000" min="50000" max="250000" step="1000"></td></tr>
 <tr><td>Percent Increase:</td><td><input type="number" name="percentIncrease" required="true" value="0.15" min="0.0" max="1.0" step="0.01"></td></tr>
 <tr><td>&nbsp;</td><td><input type="submit" value="Submit"></td></tr>
<table>
</fieldset>
</form>

</body>
</html>
