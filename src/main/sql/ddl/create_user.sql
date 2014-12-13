prompt -- create user &&app_user
prompt -- Enabling Web Services for Specific Users:
prompt -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb_web_services.htm#CHDIJGFG

prompt -- create user &&app_user identified by &&app_user_pwd
create user &&app_user identified by &&app_user_pwd
 default tablespace &&app_tablespace
 quota unlimited on &&app_tablespace
 temporary tablespace temp
 account unlock
/
grant create session to &&app_user
/

prompt -- grant xdb_webservices to &&app_user
grant xdb_webservices to &&app_user
/
prompt -- Enable use of Web services over HTTP (not just HTTPS).
grant xdb_webservices_over_http to &&app_user
/
--prompt -- Enable access, using Web services, to database objects that are accessible to PUBLIC.
--grant xdb_webservices_with_public to &&app_user
--/

prompt -- exec dbms_network_acl_admin.create_acl('&&orawsv_host..xml', 'ACL for &&orawsv_ip', upper('&&app_user'), true, 'connect')
exec dbms_network_acl_admin.create_acl('&&orawsv_host..xml', 'ACL for &&orawsv_ip', upper('&&app_user'), true, 'connect')

prompt -- exec dbms_network_acl_admin.assign_acl('&&orawsv_host..xml', '&&orawsv_ip')
exec dbms_network_acl_admin.assign_acl('&&orawsv_host..xml', '&&orawsv_ip')
