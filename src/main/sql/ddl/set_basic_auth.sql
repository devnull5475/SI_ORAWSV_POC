-- 12c XDB: 401 Unauthorized (Doc ID 1603713.1)

DECLARE
 l_configxml XMLTYPE;
 c_value constant VARCHAR2(6) := 'basic'; -- (basic/digest)
BEGIN
 l_configxml := DBMS_XDB.cfg_get();
 IF l_configxml.existsNode('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism') = 0 THEN
  -- Element should not be missing
dbms_output.put_line (' allow-mechanism element is missing ');
 ELSE
  -- Update existing element.
  SELECT updateXML
  (
  DBMS_XDB.cfg_get(),
  '/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism/text()',
  c_value,
  'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'
  )
  INTO l_configxml
  FROM dual;
  DBMS_OUTPUT.put_line('Element updated.');
 END IF;
 DBMS_XDB.cfg_update(l_configxml);
 DBMS_XDB.cfg_refresh;
END;
/
show errors

prompt -- COMMIT;

