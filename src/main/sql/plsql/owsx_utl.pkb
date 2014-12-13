prompt -- Oracle Web service Extension

prompt -- create or replace package body &&owsx_schema..owsx_utl
set termout off
create or replace package body &&owsx_schema..owsx_utl
is

 -------------------------------------------------------------------------------
 -- Oracle Web Service Extension
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 procedure pay_raise (current_salary_in in number, percent_change_in in number, new_salary_out out number )
 is
 begin
    logger.plog.info('pay_raise(curr_sal=>'||current_salary_in||', %Δ='||percent_change_in||')');
    new_salary_out := current_salary_in + (current_salary_in * percent_change_in ) ;
    logger.plog.info('pay_raise(new_sal=>'||new_salary_out||')');
 end pay_raise ;
 -------------------------------------------------------------------------------

end owsx_utl;
/
set termout on
show errors package body &&owsx_schema..owsx_utl
