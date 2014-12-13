var url varchar2(4000)

exec :url := 'http://&&app_user:&&app_user_pwd@localhost:'||dbms_xdb.getHttpPort()||'/orawsv/OWSX/OWSX_UTL/PAY_RAISE'
print url

set long 10000 pages 0
col xml for a200 word_wrapped

select HttpUriType( :url ).getXML() as xml from dual
/
