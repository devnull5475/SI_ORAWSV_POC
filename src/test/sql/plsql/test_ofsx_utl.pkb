prompt -- Oracle File system Extension: Delete from, or write arbitrarily large files to, file system.
prompt -- Using Application Contexts to Retrieve User Information: http://docs.oracle.com/cd/E25054_01/network.1111/e16543/app_context.htm

prompt -- create or replace package body &&ofsx_schema..test_ofsx_utl
set termout off
create or replace package body &&ofsx_schema..test_ofsx_utl
is

 -------------------------------------------------------------------------------
 -- Test Oracle File system Extension
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Pretend to be a PL/SQL app that wants to write a TPS report using CHAR data.
 -------------------------------------------------------------------------------
 procedure write /*A CHAR*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in varchar2,
    return_out out number,
    message_out out varchar2,
    correlation_id_io in out number,                      -- Informational only
    do_ack_in in number default &&no_,
    client_id_in in varchar2 default null )
 is
 begin
    --TODO ofsx_utl.set_context('&&is_debug', 'Y') ;
    if (trim(app_nm_in) is null or trim(fname_in) is null or trim(data_in) is null or do_ack_in<>&&no_) then
        message_out := 'ERROR: Illegal args: do_ack_in='||do_ack_in||', app_nm_in='||trim(app_nm_in)||', fname_in='||trim(fname_in)||', data.len='||length(trim(data_in)) ;
        return_out := &&no_ ;
        return ; -- short circuit
    end if;
    ofsx_utl.write /*A.CHAR*/ (
        app_nm_in         => app_nm_in,
        fname_in          => fname_in,
        data_in           => data_in,
        return_out        => return_out,
        message_out       => message_out,
        correlation_id_io => correlation_id_io,
        do_ack_in         => do_ack_in, -- should be NO
        client_id_in      => client_id_in ) ;
    if (&&yes_ = return_out ) then
     message_out := 'SUCCESS: '||message_out ;
    else
     message_out := 'FAIL: '||message_out ;
    end if;
    --ofsx_utl.set_context('&&is_debug', 'N') ;
 exception when others then
    message_out := 'ERROR: '||sqlerrm ;
    return_out := &&no_;
 end write /*A.CHAR*/ ;
 -------------------------------------------------------------------------------
 procedure write /*A CLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in clob,
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null )
 is
 begin
    --TODO ofsx_utl.set_context('&&is_debug', 'Y') ;
    if (trim(app_nm_in) is null or trim(fname_in) is null or trim(data_in) is null or do_ack_in<>&&no_) then
        message_out := 'ERROR: Illegal args: do_ack_in='||do_ack_in||', app_nm_in='||trim(app_nm_in)||', fname_in='||trim(fname_in)||', data.len='||dbms_lob.getlength(trim(data_in)) ;
        return_out := &&no_ ;
        return ; -- short circuit
    end if;
    ofsx_utl.write /*A.CLOB*/ (
        app_nm_in         => app_nm_in,
        fname_in          => fname_in,
        data_in           => data_in,
        return_out        => return_out,
        message_out       => message_out,
        correlation_id_io => correlation_id_io,
        do_ack_in         => do_ack_in, -- should be NO
        client_id_in      => client_id_in ) ;
    if (&&yes_ = return_out ) then
     message_out := 'SUCCESS: '||message_out ;
    else
     message_out := 'FAIL: '||message_out ;
    end if;
    --ofsx_utl.set_context('&&is_debug', 'N') ;
 end write /*A.CLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*A BLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in blob,
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null )
 is
 begin
    --TODO ofsx_utl.set_context('&&is_debug', 'Y') ;
    if (trim(app_nm_in) is null or trim(fname_in) is null or trim(data_in) is null or do_ack_in<>&&no_) then
        message_out := 'ERROR: Illegal args: do_ack_in='||do_ack_in||', app_nm_in='||trim(app_nm_in)||', fname_in='||trim(fname_in)||', data.len='||dbms_lob.getlength(trim(data_in)) ;
        return_out := &&no_ ;
        return ; -- short circuit
    end if;
    ofsx_utl.write /*A.BLOB*/ (
        app_nm_in         => app_nm_in,
        fname_in          => fname_in,
        data_in           => data_in,
        return_out        => return_out,
        message_out       => message_out,
        correlation_id_io => correlation_id_io,
        do_ack_in         => do_ack_in, -- should be NO
        client_id_in      => client_id_in ) ;
    if (&&yes_ = return_out ) then
     message_out := 'SUCCESS: '||message_out ;
    else
     message_out := 'FAIL: '||message_out ;
    end if;
    --ofsx_utl.set_context('&&is_debug', 'N') ;
 end write /*A.BLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B CHAR*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in varchar2,
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end write /*B.CHAR*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B CLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in clob,
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end write /*B.CLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B BLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in blob,
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end write /*B.BLOB*/ ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Delete file from location FNAME_IN using &&ofsx_text_request_queue.
 -- A. No wait
 -- B. Wait for ACK from SI
 -------------------------------------------------------------------------------
 procedure remove /*A*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location of file
    return_out out number,
    message_out out varchar2,
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end remove /*A*/ ;
 -------------------------------------------------------------------------------
 procedure remove /*B*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location of file
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end remove /*B*/ ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Move file from location SRC_IN to DEST_IN using &&ofsx_text_request_queue.
 -- A. No wait
 -- B. Wait for ACK from SI
 -------------------------------------------------------------------------------
 procedure move /*A*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    src_in in varchar2,                                   -- Assume caller knows location of files
    dest_in in varchar2,
    return_out out number,
    message_out out varchar2,
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end move /*A*/ ;
 -------------------------------------------------------------------------------
 procedure move /*B*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    src_in in varchar2,                                   -- Assume caller knows location of files
    dest_in in varchar2,
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end move /*B*/ ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Copy file from location SRC_IN to DEST_IN using &&ofsx_text_request_queue.
 -- A. No wait
 -- B. Wait for ACK from SI
 -------------------------------------------------------------------------------
 procedure copy /*A*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    src_in in varchar2,                                   -- Assume caller knows location of files
    dest_in in varchar2,
    return_out out number,
    message_out out varchar2,
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end copy /*A*/;
 -------------------------------------------------------------------------------
 procedure copy /*B*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    src_in in varchar2,                                   -- Assume caller knows location of files
    dest_in in varchar2,
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end copy /*B*/;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- IMPORT
 -------------------------------------------------------------------------------
 -- A: Enqueue request with file name. Blocking dequeue to get response.
 -- B: SI app enqueues response.
 -------------------------------------------------------------------------------
 -- IMPORT.A: Caller, PL/SQL app that wants a file imported.
 -- Synchronous request, returning file data in RESPONSE_OUT.
 -------------------------------------------------------------------------------
 procedure import /*A: PL/SQL Synchronous request that waits for response. */ (
   -----------------------------------------------------------------------------
   app_nm_in in varchar2 /*ofsx.ofsx_utl.response_t.app_name*/,                               -- Call PL/SQL app tag
   fname_in in varchar2  /*ofsx.ofsx_utl.response_t.fname*/,                                  -- Assume caller knows location of files
   type_in in varchar2   /*ofsx.ofsx_utl.response_t.msg_type*/ default '&&default_msg_type_', -- text|byte
   deq_wait_tm_in in number default &&default_deq_wait_,                                      -- Wait time in seconds.
   -----------------------------------------------------------------------------
   response_out out ofsx.ofsx_utl.response_t,
   -----------------------------------------------------------------------------
   return_out out number,
   message_out out varchar2,
   -----------------------------------------------------------------------------
   client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end import /*A*/;
 -------------------------------------------------------------------------------
 -- IMPORT.B: SI app response, providing file requested.
 -- SI response: After Java app reads file from location FNAME_IN
 --              it calls IMPORT.B to enqueue to appropriate queue.
 --              Caller uses blocking dequeue in import.A to wait for response data.
 -------------------------------------------------------------------------------
 procedure import /*B: SI Response*/ (
   -----------------------------------------------------------------------------
   cid_in in out number      /*ofsx.ofsx_utl.response_t.ofsx_id*/,  -- Request/response correlation ID
   app_nm_in in varchar2 /*ofsx.ofsx_utl.response_t.app_name*/, -- App that called SI
   fname_in in varchar2  /*ofsx.ofsx_utl.response_t.fname*/,    -- SI was told location of file
   -----------------------------------------------------------------------------
   data_char_in in varchar2 default null,                       -- File data read by SI
   data_clob_in in clob default null,
   data_byte_in in blob default null,
   -----------------------------------------------------------------------------
   return_out out number,
   message_out out varchar2,
   -----------------------------------------------------------------------------
   do_commit_in in number default &&no_,
   client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end import /*B*/ ;
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 -- Acknowlegements from SI indicating that requested file sytem work has been done.
 ------------------------------------------------------------------------------
 procedure do_ack (
   correlation_id_io in out number,         -- For this request ...
   app_nm_in in varchar2,                   -- ... from this app ...  
   is_success_in in number default &&yes_,  -- ... is SI work successful? Like RETURN_OUT from SI
   data_in in varchar2,                     -- Like MESSAGE_OUT from SI
   return_out out number,
   message_out out varchar2,
   client_id_in in varchar2 default null )
 is
 begin
    return_out := &&yes_ ;
    message_out := 'SUCCESS' ;
 end do_ack;
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 function get_version return varchar2
 is
 begin
    return '&&version_' ;
 end get_version;
 procedure pversion
 is
 begin
    dbms_output.put_line('&&version_');
 end pversion;
 ------------------------------------------------------------------------------

end test_ofsx_utl;
/
set termout on
show errors package body &&ofsx_schema..test_ofsx_utl
