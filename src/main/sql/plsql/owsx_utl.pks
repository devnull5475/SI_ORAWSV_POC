prompt -- Oracle Web service Extension

prompt -- create or replace package &&owsx_schema..owsx_utl
set termout off
create or replace package &&owsx_schema..owsx_utl
is

 -------------------------------------------------------------------------------
 -- Oracle Web Service Extension
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 procedure pay_raise (current_salary_in in number, percent_change_in in number, new_salary_out out number ) ;

end owsx_utl;
/
set termout on
show errors package &&owsx_schema..owsx_utl
