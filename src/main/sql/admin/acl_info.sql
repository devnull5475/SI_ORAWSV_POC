-- Fine-Grained Access to Network Services
-- http://oracle-base.com/articles/11g/fine-grained-access-to-network-services-11gr1.php

prompt
prompt -- View Fine-Grained Access to Network Services
prompt
pause  -- CTRL+C to abort or ENTER to continue ...

col host for a10
prompt -- SELECT * FROM DBA_NETWORK_ACLS
select host, lower_port, upper_port, acl from dba_network_acls
/

col acl for a25
col principal for a10
col is_grant for a10
col start_date for a11
col end_date for a11
prompt -- SELECT * FROM DBA_NETWORK_ACL_PRIVILEGES
SELECT acl,
       principal,
       privilege,
       is_grant,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM   dba_network_acl_privileges
/

prompt -- &&_user user_network_acl_privileges
prompt -- SELECT * FROM USER_NETWORK_ACL_PRIVILEGES
select host, lower_port, upper_port, privilege, status from user_network_acl_privileges
/

prompt
prompt -- View XDB_WEBSERVICES% Grants
prompt
pause  -- CTRL+C to abort or ENTER to continue ...

prompt -- SELECT * FROM DBA_ROLE_PRIVS
COLUMN grantee      FORMAT A20  HEAD 'user'     TRUNCATED
COLUMN granted_role FORMAT A30  HEAD 'role'     TRUNCATED
COLUMN admin_option FORMAT A10  HEAD 'admin?'   TRUNCATED
COLUMN default_role FORMAT A10  HEAD 'default?' TRUNCATED
COLUMN privilege    FORMAT A30  HEAD 'priv'     TRUNCATED
SELECT r.grantee,r.granted_role,r.admin_option,r.default_role
  FROM dba_role_privs r
 WHERE r.granted_role like 'XDB_WEB%'
ORDER BY r.grantee, r.granted_role
/
