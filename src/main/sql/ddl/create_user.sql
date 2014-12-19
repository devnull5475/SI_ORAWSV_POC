prompt -- create user &&app_user
prompt -- Enabling Web Services for Specific Users:
prompt -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb_web_services.htm#CHDIJGFG

-------------------------------------------------------------------------------
-- Create user account
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- ACL
-- http://oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1.php
-- https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_networkacl_adm.htm#ARPLS148
-- See http://&&orawsv_host:&&orawsv_port/sys/acls
-------------------------------------------------------------------------------

prompt -- exec dbms_network_acl_admin.create_acl(acl=>'&&app_user..xml', description=>'ACL for &&app_user..', principal=>upper('&&app_user'), is_grant=>true, privilege=>'connect')
exec dbms_network_acl_admin.create_acl(acl=>'&&app_user..xml', description=>'ACL for &&app_user..', principal=>upper('&&app_user'), is_grant=>true, privilege=>'connect')

prompt -- exec dbms_network_acl_admin.assign_acl(acl=>'&&app_user..xml', host=>'&&orawsv_ip')
exec dbms_network_acl_admin.assign_acl(acl=>'&&app_user..xml', host=>'&&orawsv_ip')
