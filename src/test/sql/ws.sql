define curr_=10000
accept curr_ default &&curr_ prompt 'CURR_IN (default &&curr_): '
define rper_=0.10
accept rper_ default &&rper_ prompt 'PER_RAISE_IN (default &&rper_): '
DECLARE
  C_URL VARCHAR2(750) := 'http://&&app_user:&&app_user_pwd.@127.0.0.1:8080/orawsv/OWSX/OWSX_UTL/PAY_RAISE' ;
  V_SOAP_REQUEST XMLTYPE := XMLTYPE (
'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
                    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <SOAP-ENV:Body>
    <m:PAY_RAISEInput xmlns:m="http://xmlns.oracle.com/orawsv/OWSX/OWSX_UTL/PAY_RAISE">
        <m:CURRENT_SALARY_IN-NUMBER-IN>&&curr_</m:CURRENT_SALARY_IN-NUMBER-IN>
        <m:PERCENT_CHANGE_IN-NUMBER-IN>&&rper_</m:PERCENT_CHANGE_IN-NUMBER-IN>
        <m:NEW_SALARY_OUT-NUMBER-OUT/>
    </m:PAY_RAISEInput>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>' );
  V_SOAP_REQUEST_TEXT CLOB := V_SOAP_REQUEST.getClobVal();
  V_REQUEST  UTL_HTTP.REQ;
  V_RESPONSE UTL_HTTP.RESP;
  V_BUFFER   VARCHAR2(1024);
  i number := 0 ;
BEGIN

 logger.plog.info('i='||i||': '||v_soap_request_text ) ; i := i + 1 ;

  V_REQUEST := UTL_HTTP.BEGIN_REQUEST(URL => C_URL, METHOD => 'POST');
  UTL_HTTP.SET_HEADER(V_REQUEST, 'User-Agent', 'Mozilla/4.0');
  V_REQUEST.METHOD := 'POST';
  UTL_HTTP.SET_HEADER (R => V_REQUEST, NAME => 'Content-Length', VALUE => DBMS_LOB.GETLENGTH(V_SOAP_REQUEST_TEXT));
  UTL_HTTP.WRITE_TEXT (R => V_REQUEST, DATA => V_SOAP_REQUEST_TEXT);

  V_RESPONSE := UTL_HTTP.GET_RESPONSE(V_REQUEST);
  LOOP
    UTL_HTTP.READ_LINE(V_RESPONSE, V_BUFFER, TRUE);
    --DBMS_OUTPUT.PUT_LINE(V_BUFFER);
    logger.plog.info('i='||i||': '||v_buffer);
    i := i + 1 ;
  END LOOP;
  UTL_HTTP.END_RESPONSE(V_RESPONSE);

EXCEPTION
  WHEN UTL_HTTP.END_OF_BODY THEN
    UTL_HTTP.END_RESPONSE(V_RESPONSE);
  when others then
    raise ;
END;
/
show errors
undefine curr_ rper_
