define version_=0.8-ALPHA

define yes_=1
define no_=0
define uname_sz=100

define use_log4plsql=1
--define use_log4plsql=0

define app_user=owsx
define app_user_pwd=owsx_user

define app_tablespace=USERS
prompt -- select tablespace_name, status from dba_tablespaces order by tablespace_name
select tablespace_name, status from dba_tablespaces order by tablespace_name
/
accept app_tablespace default '&&app_tablespace' prompt 'APP_TABLESPACE (default &&app_tablespace): '

define app_schema=&&app_user
define owsx_schema=&&app_user
