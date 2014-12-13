prompt -- Oracle File system Extension: Delete from, or write arbitrarily large files to, file system.
prompt -- Using Application Contexts to Retrieve User Information: http://docs.oracle.com/cd/E25054_01/network.1111/e16543/app_context.htm

prompt -- For secure application context:
prompt -- grant execute on dbms_session to &&ofsx_schema
grant execute on dbms_session to &&ofsx_schema
/
-- Creating a database session-based Application Context: http://docs.oracle.com/cd/E25054_01/network.1111/e16543/app_context.htm#i1006260
prompt -- grant create any context to &&ofsx_schema
grant create any context to &&ofsx_schema
/

prompt -- create or replace package &&ofsx_schema..ofsx_utl
set termout off
create or replace package &&ofsx_schema..ofsx_utl
is

 -------------------------------------------------------------------------------
 -- Oracle File system Extension
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -------------------------------------------------------------------------------
 -- When caller apps send a request to have a file read in by OFsX,
 -- this struct is used to return file data to caller.
 -------------------------------------------------------------------------------
 type response_t is record (
    ofsx_id    number        not null := -1, -- correlation ID, ofsx_sequence
    app_name   varchar2(25)  not null := '[PL/SQL app calling OFsX]',
    fname      varchar2(256) not null := '[File to be manipulated]',
    msg_type   varchar2(4)   not null := 'char', -- || byte
    is_suc     pls_integer   not null := &&yes_,
    length     number,
    char_data  varchar2(4000),
    clob_data  clob,
    blob_data  blob ) ;
 -------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 -- Use globally accessible secure application context to control logging or debugging.
 -- Using application contexts: http://docs.oracle.com/cd/B28359_01/network.111/b28531/app_context.htm#DBSEG98155
 ------------------------------------------------------------------------------
 -- SQL_SESS01> exec ofsx_utl.set_context('is_debug','Y')
 -- SQL_SESS02> exec :d := ofsx_utl.do_debug()
 ------------------------------------------------------------------------------
 procedure set_context ( name_in in varchar2, value_in in varchar2 ) ;
 function is_debug return boolean ;
 function is_test return boolean ;
 function do_debug return pls_integer ; -- Convenient for clients, like sqlplus, that can't do BOOLEAN
 function do_test return pls_integer ;
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 --
 -- One and only one of TEXT_MSG_IN or BYTE_MSG_IN, with appropriate QUEUE_NAME_IN.
 --
 -- AQ$_JMS_TEXT_MESSAGE  queues for TEXT_MSG_IN: &&ofsx_text_request_queue or &&ofsx_text_response_queue
 -- AQ$_JMS_BYTES_MESSAGE queues for BYTE_MSG_IN: &&ofsx_byte_request_queue or &&ofsx_byte_response_queue
 ------------------------------------------------------------------------------
 procedure enqueue (
    ---------------------------------------------------------------------------
    text_msg_in in sys.aq$_jms_text_message default null, -- One and only one of TEXT_MSG_IN or BYTE_MSG_IN
    byte_msg_in in sys.aq$_jms_bytes_message default null,
    ---------------------------------------------------------------------------
    queue_name_in in varchar2,
    ---------------------------------------------------------------------------
    return_out out number,
    message_out out varchar2,
    ---------------------------------------------------------------------------
    msg_id_out out nocopy raw,
    correlation_id_io in out number ) ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Write DATA_IN to file location FNAME_IN using &&ofsx_text_request_queue.
 -- A. No wait
 -- B. Wait for ACK from SI
 -------------------------------------------------------------------------------
 procedure write /*A CHAR*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in varchar2,
    return_out out number,
    message_out out varchar2,
    correlation_id_io in out number,                      -- Informational only
    do_ack_in in number default &&no_,
    client_id_in in varchar2 default null ) ;
 -------------------------------------------------------------------------------
 procedure write /*A CLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in clob,
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null ) ;
 -------------------------------------------------------------------------------
 procedure write /*A BLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in blob,
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
 -------------------------------------------------------------------------------
 procedure remove /*B*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location of file
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    do_commit_in in number default &&no_,                 -- Assume caller handles COMMIT/ROLLBACK
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
    client_id_in in varchar2 default null ) ;
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
   client_id_in in varchar2 default null ) ;
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
   client_id_in in varchar2 default null ) ;
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
   client_id_in in varchar2 default null ) ;
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 function get_version return varchar2 ;
 procedure pversion ;
 ------------------------------------------------------------------------------

end ofsx_utl;
/
set termout on
show errors package &&ofsx_schema..ofsx_utl

prompt -- create or replace context ofx_ctx using &&ofsx_schema..ofsx_utl accessed globally
create or replace context ofx_ctx using &&ofsx_schema..ofsx_utl accessed globally
/
