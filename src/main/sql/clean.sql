prompt
prompt -- This will completely remove OWsX from database.
prompt
pause  -- CTRL+C to abort or ENTER to continue ...

prompt -- revoke xdb_webservices from &&app_user
revoke xdb_webservices from &&app_user
/
revoke xdb_webservices_over_http from &&app_user
/
revoke xdb_webservices_with_public from &&app_user
/

prompt -- drop user &&app_user cascade
drop user &&app_user cascade
/

prompt -- exec dbms_network_acl_admin.drop_acl(acl=>'&&app_user..xml')
exec dbms_network_acl_admin.drop_acl(acl=>'&&app_user..xml')
