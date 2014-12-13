prompt -- OWSX: Oracle Web service Example

define version_=1.0

define yes_=1
define no_=0

define use_log4plsql=1
--define use_log4plsql=0

define app_user=owsx
define app_user_pwd='&&app_user._pwd'
define orawsv_host='localhost'
define orawsv_ip='127.0.0.1'
define orawsv_uri='orawsv/OWSX/OWSX_UTL/PAY_RAISE'

define app_tablespace=USERS
prompt -- select tablespace_name, status from dba_tablespaces order by tablespace_name
select tablespace_name, status from dba_tablespaces order by tablespace_name
/
accept app_tablespace default '&&app_tablespace' prompt 'APP_TABLESPACE (default &&app_tablespace): '

define app_schema=&&app_user
define owsx_schema=&&app_user
