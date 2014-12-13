var url varchar2(4000)

exec :url := 'http://&&app_user:&&app_user_pwd@&&orawsv_host.:'||dbms_xdb.getHttpPort()||'&&orawsv_uri'
print url

set long 10000 pages 0
col xml for a200 word_wrapped

select HttpUriType( :url ).getXML() as xml from dual
/
