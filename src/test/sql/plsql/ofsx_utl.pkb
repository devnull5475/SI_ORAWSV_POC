prompt -- Oracle File system Extension: Delete from, or write arbitrarily large files to, file system.
prompt -- Using Application Contexts to Retrieve User Information: http://docs.oracle.com/cd/E25054_01/network.1111/e16543/app_context.htm

prompt -- create or replace package body &&ofsx_schema..ofsx_utl
set termout on
create or replace package body &&ofsx_schema..ofsx_utl
is

 -------------------------------------------------------------------------------
 -- Oracle File system Extension
 -------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 procedure pdbg_(str_in in varchar2 )
 is
 begin
  $if &&yes_ = &&use_log4plsql $then
    plog.debug( str_in ) ;
  $else
    dbms_output.put_line( str_in ) ;
  $end
 end pdbg_ ;
 ------------------------------------------------------------------------------
 procedure perr_(str_in in varchar2 )
 is
 begin
  $if &&yes_ = &&use_log4plsql $then
    plog.error( str_in ) ;
  $else
    dbms_output.put_line( str_in ) ;
  $end
 end perr_ ;
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 procedure set_context ( name_in in varchar2, value_in in varchar2 )
 is
 begin
  dbms_session.set_context('&&app_name', name_in, value_in ) ;
 end set_context;
 ------------------------------------------------------------------------------
 function is_debug return boolean
 is
  l_val varchar2(256) ;
  cursor c is select t.value from global_context t where t.namespace=upper('&&app_name') and t.attribute=upper('&&is_debug') ;
 begin
  open c ;
  fetch c into l_val ; --dbms_output.put_line('is_debug.val='||l_val );
  if (c%notfound) then l_val := 'NO'; end if;
  if (c%isopen) then close c; end if;
  return ( upper(trim(l_val)) in ('1','T','TRUE','Y','YES' ) ) ;
 exception when others then
  perr_(sqlerrm);
  if (c%isopen) then close c; end if;
  return false ;
 end is_debug ;
 ------------------------------------------------------------------------------
 function do_debug return pls_integer
 is
 begin
  return ( case when ofsx_utl.is_debug then &&yes_ else &&no_ end ) ;
 end do_debug ; 
 ------------------------------------------------------------------------------
 function is_test return boolean
 is
  l_val varchar2(256) ;
  cursor c is select t.value from global_context t where t.namespace=upper('&&app_name') and t.attribute=upper('&&is_test') ;
 begin
  open c ;
  fetch c into l_val ; --dbms_output.put_line('is_test.val='||l_val );
  if (c%notfound) then l_val := 'NO'; end if;
  if (c%isopen) then close c; end if;
  return ( upper(trim(l_val)) in ('1','T','TRUE','Y','YES' ) ) ;
 exception when others then
  perr_(sqlerrm);
  if (c%isopen) then close c; end if;
  return false ;
 end is_test ;
 ------------------------------------------------------------------------------
 function do_test return pls_integer
 is
 begin
  return ( case when ofsx_utl.is_test then &&yes_ else &&no_ end ) ;
 end do_test ; 
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 --
 -- One and only one of TEXT_MSG_IN or BYTE_MSG_IN, with appropriate QUEUE_NAME_IN.
 --
 -- AQ$_JMS_TEXT_MESSAGE  queues for TEXT_MSG_IN: &&ofsx_text_request_queue or &&ofsx_text_response_queue
 -- AQ$_JMS_BYTES_MESSAGE queues for BYTE_MSG_IN: &&ofsx_byte_request_queue or &&ofsx_byte_response_queue
 ------------------------------------------------------------------------------
 procedure enqueue (
  -----------------------------------------------------------------------------
  text_msg_in in sys.aq$_jms_text_message default null, -- One and only one of TEXT_MSG_IN or BYTE_MSG_IN
  byte_msg_in in sys.aq$_jms_bytes_message default null,
  -----------------------------------------------------------------------------
  queue_name_in in varchar2,
  -----------------------------------------------------------------------------
  return_out out number,
  message_out out varchar2,
  -----------------------------------------------------------------------------
  msg_id_out out nocopy raw,
  correlation_id_io in out number )
 is
  pragma autonomous_transaction ;
  c_type constant varchar2(4) := case when text_msg_in is not null then '&&ofsx_ft_text' else '&&ofsx_ft_byte' end ; 
  l_enqueue_options dbms_aq.enqueue_options_t;
  l_message_properties dbms_aq.message_properties_t;
  l_message_handle RAW(16);
  -----------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  -----------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.enqueue(q$='||queue_name_in||','||c_type||')'); end if;
  -----------------------------------------------------------------------------
  -- Sanity
  -----------------------------------------------------------------------------
  if ( (text_msg_in is null and byte_msg_in is null) or
       (text_msg_in is not null and byte_msg_in is not null) )
  then
    return_out := &&no_ ;
    message_out := 'Illegal argument: TEXT_MSG_IN or BYTE_MSG_IN, but not both.';
    perr_('ofsx_utl.enqueue(q$='||queue_name_in||','||c_type||'): '||message_out);
    return ; -- short circuit
  end if;
  if ( (text_msg_in is not null and lower(queue_name_in) not in (lower('&&ofsx_text_request_queue'),lower('&&ofsx_text_response_queue')) ) or
       (byte_msg_in is not null and lower(queue_name_in) not in (lower('&&ofsx_byte_request_queue'),lower('&&ofsx_byte_response_queue')) ) )
  then
    return_out := &&no_ ;
    message_out := 'Illegal state: For TEXT_MSG_IN, QUEUE_NAME_IN must be in (&&ofsx_text_request_queue,&&ofsx_text_response_queue). For BYTE_MSG_IN, QUEUE_NAME_IN must be in (&&ofsx_byte_request_queue,&&ofsx_byte_response_queue).';
    perr_('ofsx_utl.enqueue(q$='||queue_name_in||','||c_type||'): '||message_out);
    return ; -- short circuit
  end if;
  -----------------------------------------------------------------------------
  -- correlation_id
  -----------------------------------------------------------------------------
  if (correlation_id_io is null ) then
    select ofsx.ofsx_sequence.nextval into correlation_id_io from dual ;
  end if;
  l_message_properties.correlation := to_char( correlation_id_io ) ;
  -----------------------------------------------------------------------------
  -- Enqueue
  -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1001648
  -----------------------------------------------------------------------------
  if (text_msg_in is not null ) then
    dbms_aq.enqueue (
      queue_name           => queue_name_in,
      enqueue_options      => l_enqueue_options,
      message_properties   => l_message_properties,
      msgid                => l_message_handle,
      payload              => text_msg_in ) ;
  else
    dbms_aq.enqueue (
      queue_name           => queue_name_in,
      enqueue_options      => l_enqueue_options,
      message_properties   => l_message_properties,
      msgid                => l_message_handle,
      payload              => byte_msg_in ) ;
  end if;
  -----------------------------------------------------------------------------
  -- Feedback
  -----------------------------------------------------------------------------
  return_out := case when l_message_handle is not null then &&yes_ else &&no_ end ;
  message_out := 'OK '||queue_name_in||' cid='||correlation_id_io||', enq.mid='||rawtohex(l_message_handle)||';';
  msg_id_out := l_message_handle ;
  -----------------------------------------------------------------------------
  -- COMMIT autonomous tx
  -----------------------------------------------------------------------------
  commit comment 'ofsx auto.tx' ;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.enqueue(q$='||queue_name_in||','||c_type||') cid='||correlation_id_io||', enq.mid='||rawtohex(l_message_handle)); end if;
 exception when others then
  message_out := 'ofsx_utl.enqueue(q$='||queue_name_in||','||c_type||') prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_(message_out);
  rollback ; -- autonomous tx
 end enqueue;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -------------------------------------------------------------------------------
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Write DATA_IN to file location FNAME_IN using &&ofsx_text_request_queue and &&ofsx_text_response_queue.
 -------------------------------------------------------------------------------
 procedure write /*A CHAR*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in varchar2,                                  -- Character data to be written to file system.
    return_out out number,
    message_out out varchar2,
    correlation_id_io in out number,
    do_ack_in in number default &&no_,
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := length(data_in ) ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_message sys.aq$_jms_text_message;
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.write.A.CHAR(fn='||fname_in||',len='||c_len||',q$=&&ofsx_text_request_queue)') ; end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  if (c_len <= 4000 ) then
   l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>c_len, text_vc=>data_in, text_lob=>null ) ;
  else
   l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>c_len, text_vc=>null, text_lob=>data_in ) ;
  end if;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
  l_message.set_string_property ('&&ofsx_prop_src', fname_in ) ;
  l_message.set_string_property ('&&ofsx_prop_op' , '&&ofsx_op_write' ) ;
  l_message.set_string_property ('&&ofsx_prop_ft' , '&&ofsx_ft_text' ) ; -- Not necessary because SI can use request AQ$_JMS_TEXT_MESSAGE == Message<String> to know what kind of file to write.
  l_message.set_int_property    ('&&ofsx_prop_ack', do_ack_in ) ;
  -----------------------------------------------------------------------------
  -- Enqueue. Autonomous transaction.
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    text_msg_in       => l_message,
    return_out        => return_out,
    message_out       => message_out,
    msg_id_out        => l_message_handle,
    queue_name_in     => '&&ofsx_text_request_queue',
    correlation_id_io => correlation_id_io ) ; if c_dbg then pdbg_('ofsx_utl.write.A.CHAR(fn='||fname_in||',len='||c_len||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||', enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.write.A.CHAR(fn='||fname_in||',len='||c_len||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'write.A.CHAR(&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.A.CHAR(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue): '||message_out);
 end write /*A CHAR*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B CHAR*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in varchar2,                                  -- Character data to be written to file system.
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := length(data_in ) ;
  c_deq_wait_time constant number := nvl(deq_wait_tm_in, &&default_deq_wait_ ) ;
  c_response_queue constant varchar2(25) := '&&ofsx_text_response_queue' ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_deq_options dbms_aq.dequeue_options_t;
  l_response_text sys.aq$_jms_text_message;          -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
  l_message_properties dbms_aq.message_properties_t;
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.write.B.CHAR(app='||app_nm_in||',fn='||fname_in||',len='||c_len||',q$=&&ofsx_text_request_queue)') ; end if;
  -----------------------------------------------------------------------------
  ofsx_utl.write/*A CHAR*/ (
    app_nm_in         => app_nm_in,
    fname_in          => fname_in,
    data_in           => data_in,
    return_out        => return_out,
    message_out       => message_out,
    do_ack_in         => &&yes_,
    correlation_id_io => correlation_id_io,
    client_id_in      => client_id_in ) ; if c_dbg then pdbg_('ofsx_utl.write.B.CHAR(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||', ret='||return_out ); end if;
  if (&&yes_ = return_out and correlation_id_io is not null ) then
    ---------------------------------------------------------------------------
    -- RESPONSE: BLOCKING DEQUEUE
    -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1000252
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    l_deq_options.correlation := to_char(correlation_id_io ) ;
    l_deq_options.wait := c_deq_wait_time ;
    dbms_aq.dequeue (
       queue_name         => c_response_queue,
       dequeue_options    => l_deq_options,
       message_properties => l_message_properties,
       payload            => l_response_text,
       msgid              => l_message_handle ) ;
    ---------------------------------------------------------------------------
    -- RESPONSE_OUT: Simple ACK. DO_ACK added IS_SUC; we add a few more attribs
    ---------------------------------------------------------------------------
    response_out.fname    := fname_in ;
    response_out.msg_type := lower('&&ofsx_ft_text') ;
    response_out.length   := case when trim(response_out.char_data) is not null then length(response_out.char_data) else -1 end ;
    l_response_text.get_text (payload => response_out.char_data ) ;
  else
    pdbg_('ofsx_utl.write.B.CHAR(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||', ret='||return_out||', msg='||message_out );
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  return_out := case when response_out.is_suc = &&yes_ then &&yes_ else &&no_ end ;
  message_out := substr('cid='||correlation_id_io||', mid='||l_message_handle||', response.vc='||response_out.char_data,1,4000);
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  if (c_dbg ) then pdbg_('finish ofsx_utl.import.B.CHAR(app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type=&&ofsx_ft_text) cid='||correlation_id_io ); end if;
  ---------------------------------------------------------------------------
 exception when others then
  message_out := 'write.B.CHAR(&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.B.CHAR(app='||app_nm_in||',fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||': '||message_out);
 end write /*B CHAR*/ ;
 -------------------------------------------------------------------------------
 procedure write /*A CLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in clob,                                      -- Character data to be written to file system.
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := dbms_lob.getlength(data_in ) ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_message sys.aq$_jms_text_message;
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin write.A.CLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>c_len, text_vc=>null, text_lob=>data_in ) ;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
  l_message.set_string_property ('&&ofsx_prop_src', fname_in ) ;
  l_message.set_string_property ('&&ofsx_prop_op' , '&&ofsx_op_write' ) ;
  l_message.set_string_property ('&&ofsx_prop_ft' , '&&ofsx_ft_text' ) ; -- Not necessary because SI can use request AQ$_JMS_TEXT_MESSAGE == Message<String> to know what kind of file to write.
  l_message.set_int_property    ('&&ofsx_prop_ack', do_ack_in ) ;
  -----------------------------------------------------------------------------
  -- Enqueue. Autonomous transaction.
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    text_msg_in       => l_message,
    return_out        => return_out,
    message_out       => message_out,
    correlation_id_io => correlation_id_io,
    queue_name_in     => '&&ofsx_text_request_queue',
    msg_id_out        => l_message_handle ) ; if c_dbg then pdbg_('write.A.CLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue): cid='||correlation_id_io||', enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish write.A.CLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'write.A.CLOB(&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.A.CLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue): '||message_out);
 end write /*A CLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B CLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in CLOB,                                      -- Character data to be written to file system.
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := length(data_in ) ;
  c_deq_wait_time constant number := nvl(deq_wait_tm_in, &&default_deq_wait_ ) ;
  c_response_queue constant varchar2(25) := '&&ofsx_text_response_queue' ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_deq_options dbms_aq.dequeue_options_t;
  l_message_properties dbms_aq.message_properties_t;
  l_response_text sys.aq$_jms_text_message;          -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.write.B.CLOB(app='||app_nm_in||',fn='||fname_in||',len='||c_len||',q$=&&ofsx_text_request_queue)') ; end if;
  -----------------------------------------------------------------------------
  ofsx_utl.write/*A CLOB*/ (
    app_nm_in         => app_nm_in,
    fname_in          => fname_in,
    data_in           => data_in,
    return_out        => return_out,
    message_out       => message_out,
    do_ack_in         => &&yes_,
    correlation_id_io => correlation_id_io,
    client_id_in      => client_id_in ) ; if c_dbg then pdbg_('ofsx_utl.write.B.CLOB(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||', ret='||return_out ); end if;
  if (&&yes_ = return_out and correlation_id_io is not null ) then
    ---------------------------------------------------------------------------
    -- RESPONSE: BLOCKING DEQUEUE
    -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1000252
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    l_deq_options.correlation := to_char(correlation_id_io ) ;
    l_deq_options.wait := c_deq_wait_time ;
    dbms_aq.dequeue (
       queue_name         => c_response_queue,
       dequeue_options    => l_deq_options,
       message_properties => l_message_properties,
       payload            => l_response_text,
       msgid              => l_message_handle ) ;
    ---------------------------------------------------------------------------
    -- RESPONSE_OUT: Simple ACK. DO_ACK added IS_SUC; we add a few more attribs
    ---------------------------------------------------------------------------
    response_out.fname    := fname_in ;
    response_out.msg_type := lower('&&ofsx_ft_text') ;
    response_out.length   := case when trim(response_out.char_data) is not null then length(response_out.char_data) else -1 end ;
    l_response_text.get_text (payload => response_out.char_data ) ;
  else
    pdbg_('ofsx_utl.write.B.CLOB(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||', ret='||return_out||', msg='||message_out );
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  return_out := case when response_out.is_suc = &&yes_ then &&yes_ else &&no_ end ;
  message_out := substr('cid='||correlation_id_io||', mid='||l_message_handle||', response.vc='||response_out.char_data,1,4000);
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  if (c_dbg ) then pdbg_('finish ofsx_utl.import.B.CLOB(app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type=&&ofsx_ft_text) cid='||correlation_id_io ); end if;
  ---------------------------------------------------------------------------
 exception when others then
  message_out := 'write.B.CLOB(&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.B.CLOB(app='||app_nm_in||',fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_text_request_queue) cid='||correlation_id_io||': '||message_out);
 end write /*B CLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*A BLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in blob,                                      -- Bytes to be written to the file system.
    return_out out number,
    message_out out varchar2,
    do_ack_in in number default &&no_,
    correlation_id_io in out number,                      -- Informational only
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := dbms_lob.getlength(data_in ) ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_message sys.aq$_jms_bytes_message;
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin write.A.BLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_byte_request_queue)'); end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  l_message := sys.aq$_jms_bytes_message( header=>null/*sys.aq$_jms_header*/, bytes_len=>c_len, bytes_raw=>null, bytes_lob=>data_in ) ;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
  l_message.set_string_property ('&&ofsx_prop_src', fname_in ) ;
  l_message.set_string_property ('&&ofsx_prop_op', '&&ofsx_op_write' ) ;
  l_message.set_string_property ('&&ofsx_prop_ft', '&&ofsx_ft_byte' ) ; -- Not necessary because SI can use request AQ$_JMS_BYTES_MESSAGE == Message<byte[]> to know what kind of file to write.
  l_message.set_int_property    ('&&ofsx_prop_ack', do_ack_in ) ;
  -----------------------------------------------------------------------------
  -- Enqueue. Autonomous transaction.
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    byte_msg_in       => l_message,
    return_out        => return_out,
    message_out       => message_out,
    queue_name_in     => '&&ofsx_byte_request_queue',
    msg_id_out        => l_message_handle,
    correlation_id_io => correlation_id_io ) ; if c_dbg then pdbg_('write.A.BLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_byte_request_queue): cid='||correlation_id_io||', enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish write.A.BLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_byte_request_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'write.A.BLOB(&&ofsx_byte_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.A.BLOB(fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_byte_request_queue) cid='||correlation_id_io||': '||message_out);
 end write /*A BLOB*/ ;
 -------------------------------------------------------------------------------
 procedure write /*B BLOB*/ (
    app_nm_in in varchar2,                                -- Caller PL/SQL app tag
    fname_in in varchar2,                                 -- Assume caller knows location file will be written to
    data_in in BLOB,                                      -- Bytes to be written to file system.
    return_out out number,
    message_out out varchar2,
    deq_wait_tm_in in number default &&default_deq_wait_, -- Time in seconds to wait before dequeuing ACK
    response_out out ofsx.ofsx_utl.response_t,            -- ACK data struct
    correlation_id_io in out number,
    client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := length(data_in ) ;
  c_deq_wait_time constant number := nvl(deq_wait_tm_in, &&default_deq_wait_ ) ;
  c_response_queue constant varchar2(25) := '&&ofsx_text_response_queue' ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_deq_options dbms_aq.dequeue_options_t;
  l_message_properties dbms_aq.message_properties_t;
  l_response_text sys.aq$_jms_text_message;          -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.write.B.BLOB(app='||app_nm_in||',fn='||fname_in||',len='||c_len||',q$=&&ofsx_byte_request_queue)') ; end if;
  -----------------------------------------------------------------------------
  ofsx_utl.write/*A BLOB*/ (
    app_nm_in         => app_nm_in,
    fname_in          => fname_in,
    data_in           => data_in,
    return_out        => return_out,
    message_out       => message_out,
    do_ack_in         => &&yes_,
    correlation_id_io => correlation_id_io,
    client_id_in      => client_id_in ) ; if c_dbg then pdbg_('ofsx_utl.write.B.BLOB(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_byte_request_queue) cid='||correlation_id_io||', ret='||return_out ); end if;
  if (&&yes_ = return_out and correlation_id_io is not null ) then
    ---------------------------------------------------------------------------
    -- RESPONSE: BLOCKING DEQUEUE
    -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1000252
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    l_deq_options.correlation := to_char(correlation_id_io ) ;
    l_deq_options.wait := c_deq_wait_time ;
    dbms_aq.dequeue (
       queue_name         => c_response_queue,
       dequeue_options    => l_deq_options,
       message_properties => l_message_properties,
       payload            => l_response_text,
       msgid              => l_message_handle ) ;
    ---------------------------------------------------------------------------
    -- RESPONSE_OUT: Simple ACK. DO_ACK added IS_SUC; we add a few more attribs
    ---------------------------------------------------------------------------
    response_out.fname    := fname_in ;
    response_out.msg_type := lower('&&ofsx_ft_byte') ;
    response_out.length   := case when trim(response_out.char_data) is not null then length(response_out.char_data) else -1 end ;
    l_response_text.get_text (payload => response_out.char_data ) ;
  else
    pdbg_('ofsx_utl.write.B.BLOB(app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_byte_request_queue) cid='||correlation_id_io||', ret='||return_out||', msg='||message_out );
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  return_out := case when response_out.is_suc = &&yes_ then &&yes_ else &&no_ end ;
  message_out := substr('cid='||correlation_id_io||', mid='||l_message_handle||', response.vc='||response_out.char_data,1,4000);
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  if (c_dbg ) then pdbg_('finish ofsx_utl.import.B.BLOB(cid='||correlation_id_io||',app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type=&&ofsx_ft_byte)'); end if;
  ---------------------------------------------------------------------------
 exception when others then
  message_out := 'write.B.BLOB(&&ofsx_byte_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.write.B.BLOB(app='||app_nm_in||',fn='||fname_in||',data.len='||c_len||',q$=&&ofsx_byte_request_queue) cid='||correlation_id_io||': '||message_out);
 end write /*B BLOB*/ ;
 -------------------------------------------------------------------------------
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Synchronous request, returning file data in RESPONSE_OUT.
 -- 1. Enqueue request with file name
 -- 2. SI app uses import.B to enqueue response.
 -- 3. Blocking dequeue to get response.
 -------------------------------------------------------------------------------
 procedure import /*A: PL/SQL Synchronous request that waits for response. */ (
   -----------------------------------------------------------------------------
   -- KEY
   -----------------------------------------------------------------------------
   app_nm_in in varchar2 /*ofsx.ofsx_utl.response_t.app_name*/,                               -- App tag
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
   -----------------------------------------------------------------------------
   c_dbg constant boolean := ofsx_utl.is_debug ;
   c_user constant varchar2(&&uname_sz) := user ;
   c_deq_wait_time constant number := nvl(deq_wait_tm_in, &&default_deq_wait_ ) ;
   c_response_queue constant varchar2(25) := case when type_in = 'text' then '&&ofsx_text_response_queue' else 'ofsx_byte_response_queue' end ;
   -----------------------------------------------------------------------------
   l_message_handle raw(16);
   l_cid number ;                                     -- message correlation ID, carried by both request and response
   l_request sys.aq$_jms_text_message;                -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
   l_response_text sys.aq$_jms_text_message;          -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
   l_response_byte sys.aq$_jms_bytes_message;         -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i1244160
   l_deq_options dbms_aq.dequeue_options_t ;          -- http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/t_aq.htm#CBABBDGH
   l_message_properties dbms_aq.message_properties_t; -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_aq.htm#i997396
   -----------------------------------------------------------------------------
 begin
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   if (c_dbg ) then pdbg_('begin ofsx_utl.import.A(app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type='||type_in||')'); end if;
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Sanity
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   if (app_nm_in is null or fname_in is null ) then
     return_out := &&no_ ;
     message_out := 'Illegal args: APP_NM_IN and FNAME_IN required.';
     perr_('ofsx_utl.import.A(app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type='||type_in||'): '||message_out ) ;
     return ; -- short circuit ;
   end if;
   if (type_in is null or lower(type_in) not in ('text','byte')) then
     return_out := &&no_ ;
     message_out := 'Illegal args: TYPE_IN should be text or byte.' ;
     perr_('ofsx_utl.import.A(app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type='||type_in||'): '||message_out ) ;
     return ; -- short circuit ;
   end if;
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Simple text message used to request file import.
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   l_request := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>length(trim(fname_in)), text_vc=>trim(fname_in), text_lob=>null ) ;
   l_request.set_userid (c_user ) ;
   l_request.set_string_property ('&&ofsx_prop_ft', lower(type_in) ) ;
   l_request.set_string_property ('&&ofsx_prop_src', fname_in ) ;
   l_request.set_string_property ('&&ofsx_prop_op', '&&ofsx_op_read' ) ;
   l_request.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- REQUEST: ENQUEUE. COMMITs autonomous tx
   -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1001648
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ofsx_utl.enqueue (
    text_msg_in        => l_request,
    queue_name_in      => '&&ofsx_text_request_queue',
    return_out         => return_out,
    message_out        => message_out,
    msg_id_out         => l_message_handle,
    correlation_id_io  => l_cid ) ; if c_dbg then pdbg_('ofsx_utl.import.A(cid='||l_cid||',app='||app_nm_in||',fn='||fname_in||',q$=&&ofsx_text_request_queue): enq.msgid='||l_message_handle); end if;
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   -- RESPONSE: BLOCKING DEQUEUE
   -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_aq.htm#i1000252
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   l_deq_options.correlation := to_char(l_cid ) ;
   l_deq_options.wait := c_deq_wait_time ;
   if (lower(type_in) = lower('&&ofsx_ft_text')) then
     dbms_aq.dequeue (
       queue_name         => c_response_queue,
       dequeue_options    => l_deq_options,
       message_properties => l_message_properties,
       payload            => l_response_text,
       msgid              => l_message_handle ) ;
   else
     dbms_aq.dequeue (
       queue_name         => c_response_queue,
       dequeue_options    => l_deq_options,
       message_properties => l_message_properties,
       payload            => l_response_byte,
       msgid              => l_message_handle ) ;
   end if;
   ---------------------------------------------------------------------------
   -- RESPONSE_OUT
   ---------------------------------------------------------------------------
   response_out.ofsx_id  := l_cid ;
   response_out.app_name := app_nm_in ;
   response_out.fname    := fname_in ;
   response_out.msg_type := lower(type_in) ;
   if (lower(type_in)='text') then
     l_response_text.get_text (payload => response_out.char_data ) ;
     l_response_text.get_text (payload => response_out.clob_data ) ;
     response_out.length := case when trim(response_out.char_data) is not null then length(response_out.char_data) else dbms_lob.getlength(response_out.clob_data) end ;
   else
     l_response_byte.get_bytes (payload => response_out.blob_data ) ;
     response_out.length := dbms_lob.getlength(response_out.blob_data) ;
   end if;
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   return_out := &&yes_ ;
   message_out := 'cid='||l_cid||', mid='||l_message_handle||', data.len='||response_out.length ;
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   if (c_dbg ) then pdbg_('finish ofsx_utl.import.A(cid='||l_cid||',app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type='||type_in||')'); end if;
   ---------------------------------------------------------------------------
 exception when others then
    message_out := 'ofsx_utl.import.A(cid='||l_cid||',app='||app_nm_in||',fn='||fname_in||',wait='||c_deq_wait_time||',type='||type_in||') prob: '||sqlerrm ;
    return_out := &&no_ ;
    perr_(message_out ) ;
    --raise ; -- Don't RAISE; let RETURN_OUT and MESSAGE_OUT inform caller.
 end import /*A*/ ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- SI response: After Java app reads file from location FNAME_IN
 --              it enqueues to appropriate queue. Caller uses blocking dequeue
 --              in import.A to get response data.
 -------------------------------------------------------------------------------
 procedure import /*B: SI Response*/ (
   -----------------------------------------------------------------------------
   -- KEYS
   -----------------------------------------------------------------------------
   cid_in in out number, --  TODO     /*ofsx.ofsx_utl.response_t.ofsx_id*/,  -- Request/response correlation ID
   app_nm_in in varchar2 /*ofsx.ofsx_utl.response_t.app_name*/, -- App that called SI
   fname_in in varchar2  /*ofsx.ofsx_utl.response_t.fname*/,    -- SI was told location of file
   -----------------------------------------------------------------------------
   data_char_in in varchar2,
   data_clob_in in clob,
   data_byte_in in blob,
   -----------------------------------------------------------------------------
   return_out out number,
   message_out out varchar2,
   -----------------------------------------------------------------------------
   do_commit_in in number default &&no_,
   client_id_in in varchar2 default null ) 
 is
  ------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_user constant varchar2(&&uname_sz) := user ;
  c_type constant varchar2(4) := case when trim(data_char_in) is not null or data_clob_in is not null then 'text' else 'byte' end ;
  c_len constant number := case when data_clob_in is not null then dbms_lob.getlength(data_clob_in) when data_byte_in is not null then dbms_lob.getlength(data_byte_in) when data_char_in is not null then length(data_char_in) else 0 end ;
  c_response_queue constant varchar2(25) := case when c_type = 'text' then '&&ofsx_text_response_queue' else 'ofsx_byte_response_queue' end ;
  ------------------------------------------------------------------------------
  l_response_text sys.aq$_jms_text_message;          -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i996967
  l_response_byte sys.aq$_jms_bytes_message;         -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_jms.htm#i1244160
  l_message_properties dbms_aq.message_properties_t; -- http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/t_aq.htm#i997396
  l_message_handle raw(16);
  ------------------------------------------------------------------------------
 begin
  ---------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||')' ) ; end if;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Sanity
  ---------------------------------------------------------------------------
  -- Not empty data
  ---------------------------------------------------------------------------
  if (0 = c_len ) then
    message_out := 'Illegal args: DATA_CLOB_IN is empty and DATA_CHAR_IN is empty and DATA_BYTE_IN is empty' ;
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out ) ;
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  -- One of DATA_CLOB_IN, DATA_BYTE_IN or DATA_CHAR_IN not null.
  ---------------------------------------------------------------------------
  if (data_clob_in is null and data_char_in is null and data_byte_in is null ) then
    message_out := 'data_clob_in is null and data_char_in is null and data_byte_in is null' ;
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
    return ; -- short circuit
  elsif (data_clob_in is not null and data_char_in is not null ) then
    message_out := 'data_clob_in is not null and data_char_in is not null' ;
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
    return ; -- short circuit
  elsif (data_clob_in is not null and data_byte_in is not null ) then
    message_out := 'data_clob_in is not null and data_byte_in is not null' ;
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
    return ; -- short circuit
  elsif (data_char_in is not null and data_byte_in is not null ) then
    message_out := 'data_char_in is not null and data_byte_in is not null' ;
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  -- FNAME + APP_NAME key present.
  ---------------------------------------------------------------------------
  if (cid_in is null or trim(fname_in) is null or trim(app_nm_in ) is null ) then
    message_out := 'ofsx_utl.import.B CORRELATION_ID, FNAME_IN, and APP_NM_IN are required OFSX key. FNAME_IN='||trim(fname_in)||', APP_NM_IN='||trim(app_nm_in);
    return_out := &&no_ ;
    perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
    return ; -- short circuit
  end if;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- ENQUEUE
  -----------------------------------------------------------------------------
  if (c_type = '&&ofsx_ft_text' ) then
   l_response_text := sys.aq$_jms_text_message( header=>null, text_len=>c_len, text_vc=>data_char_in, text_lob=>data_clob_in ) ;
   l_response_text.set_userid (c_user ) ;
   l_response_text.set_string_property ('&&ofsx_prop_ft', lower(c_type) ) ;
   l_response_text.set_string_property ('&&ofsx_prop_src', fname_in ) ;
   l_response_text.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
   ofsx_utl.enqueue (
    text_msg_in       => l_response_text,
    queue_name_in     => c_response_queue, --&&ofsx_text_response_queue
    return_out        => return_out,
    message_out       => message_out,
    msg_id_out        => l_message_handle,
    correlation_id_io => cid_in ) ;
  else
   l_response_byte := sys.aq$_jms_bytes_message( header=>null, bytes_len=>c_len, bytes_raw=>null, bytes_lob=>data_byte_in ) ;
   l_response_text.set_userid (c_user ) ;
   l_response_text.set_string_property ('&&ofsx_prop_ft', lower(c_type) ) ;
   l_response_text.set_string_property ('&&ofsx_prop_src', fname_in ) ;
   l_response_text.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
   ofsx_utl.enqueue (
    byte_msg_in       => l_response_byte,
    queue_name_in     => c_response_queue, --&&ofsx_byte_response_queue
    return_out        => return_out,
    message_out       => message_out,
    msg_id_out        => l_message_handle,
    correlation_id_io => cid_in ) ;
  end if;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- COMMIT?
  -----------------------------------------------------------------------------
  if (&&yes_ = do_commit_in ) then
    if (&&yes_ = return_out ) then
        commit ;
    else
        rollback;
    end if;
  end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'ofsx_utl.import.B prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.import.B(cid='||cid_in||',type='||c_type||',fname='||fname_in||',app='||app_nm_in||',data.len='||c_len||'): '||message_out);
  if (&&yes_ = do_commit_in ) then rollback ; end if;
  --raise; -- Use RETURN_OUT and MESSAGE_OUT instead of RAISE
 end import ;
 -------------------------------------------------------------------------------
 

 -------------------------------------------------------------------------------
 -- Delete file from location FNAME_IN using using &&ofsx_text_request_queue (and &&ofsx_text_response_queue, if desired).
 -------------------------------------------------------------------------------
 procedure remove (
  app_nm_in in varchar2,                -- Caller PL/SQL app tag
  fname_in in varchar2,                 -- Assume caller knows location of file
  return_out out number,
  message_out out varchar2,
  do_commit_in in number default &&no_, -- Assume caller handles COMMIT/ROLLBACK
  client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  l_todo number ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_message sys.aq$_jms_text_message;
  c_user constant varchar2(&&uname_sz) := user ;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin remove(fn='||fname_in||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
  -- Sanity
  -----------------------------------------------------------------------------
  if (trim(fname_in) is null ) then
    return_out := &&no_ ;
    message_out := 'Illegal arg: FNAME_IN required' ;
    perr_('ofsx_utl.remove: '||message_out);
    return ; -- short circuit
  end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>length(trim(fname_in)), text_vc=>trim(fname_in), text_lob=>null ) ;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_caller', nvl(trim(client_id_in), c_user ) ) ;
  l_message.set_string_property ('&&ofsx_prop_src', fname_in ) ;
  l_message.set_string_property ('&&ofsx_prop_op', '&&ofsx_op_delete' ) ;
  -----------------------------------------------------------------------------
  -- Enqueue
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    text_msg_in  => l_message,
    return_out   => return_out,
    message_out  => message_out,
    queue_name_in => '&&ofsx_text_request_queue',
    correlation_id_io => l_todo,
    msg_id_out   => l_message_handle ) ; if c_dbg then pdbg_('ofsx_utl.remove: enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  -- COMMIT?
  -----------------------------------------------------------------------------
  if (&&yes_ = do_commit_in ) then commit ; end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.remove(fn='||fname_in||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'remove(&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_('ofsx_utl.remove: '||message_out);
  if (&&yes_ = do_commit_in ) then rollback ; end if;
 end remove ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
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
    null;
 end remove /*B*/ ;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Move file from location SRC_IN to DEST_IN using &&ofsx_text_request_queue and, optionally, &&ofsx_text_response_queue.
 -------------------------------------------------------------------------------
 procedure move (
  app_nm_in in varchar2,                -- Caller PL/SQL app tag
  src_in in varchar2,                   -- Assume caller knows location of files
  dest_in in varchar2,
  return_out out number,
  message_out out varchar2,
  do_commit_in in number default &&no_, -- Assume caller handles COMMIT/ROLLBACK
  client_id_in in varchar2 default null )
 is
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug;
  -------------------------------------------------------------------------------
  l_todo number ;
  l_message_handle RAW(16);
  l_message sys.aq$_jms_text_message;
  c_user constant varchar2(&&uname_sz) := user;
  -------------------------------------------------------------------------------
 begin
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.move(src='||src_in||',dest='||dest_in||',q$=&&ofsx_text_request_queue)') ; end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>0, text_vc=>null, text_lob=>null ) ;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_src', src_in ) ;
  l_message.set_string_property ('&&ofsx_prop_dst', dest_in ) ;
  l_message.set_string_property ('&&ofsx_prop_op',  '&&ofsx_op_move' ) ;
  -----------------------------------------------------------------------------
  -- Enqueue
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    text_msg_in  => l_message,
    queue_name_in => '&&ofsx_text_request_queue',
    return_out   => return_out,
    message_out  => message_out,
    correlation_id_io => l_todo,
    msg_id_out   => l_message_handle ) ; if c_dbg then pdbg_('ofsx_utl.move enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  -- COMMIT?
  -----------------------------------------------------------------------------
  if (&&yes_ = do_commit_in ) then commit ; end if;
  -----------------------------------------------------------------------------
  -- DBG
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.move(src='||src_in||',dest='||dest_in||',q$=&&ofsx_text_request_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'ofsx_utl.move(src='||src_in||',dest='||dest_in||',q$=&&ofsx_text_request_queue) prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_(message_out);
  if (&&yes_ = do_commit_in ) then rollback ; end if;
 end move /*A*/ ;
 -------------------------------------------------------------------------------

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
    null;
 end move /*B*/; 
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 -- Copy file from location SRC_IN to DEST_IN using &&ofsx_text_request_queue and, optionally, &&ofsx_text_response_queue.
 -------------------------------------------------------------------------------
 procedure copy (
  app_nm_in in varchar2,                -- Caller PL/SQL app tag
  src_in in varchar2,                   -- Assume caller knows location of files
  dest_in in varchar2,
  return_out out number,
  message_out out varchar2,
  do_commit_in in number default &&no_, -- Assume caller handles COMMIT/ROLLBACK
  client_id_in in varchar2 default null )
 is
 begin
    null;
 end copy /*A*/;
 -------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
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
    null;
 end copy /*B*/;
 -------------------------------------------------------------------------------

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
  -------------------------------------------------------------------------------
  c_dbg constant boolean := ofsx_utl.is_debug ;
  c_len constant number := length(data_in ) ;
  -------------------------------------------------------------------------------
  l_message_handle RAW(16);
  l_message sys.aq$_jms_text_message;
  c_user constant varchar2(&&uname_sz) := user ;
 begin
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('begin ofsx_utl.do_ack(app='||app_nm_in||',cid='||correlation_id_io||',msg='||data_in||',q$=&&ofsx_text_response_queue)'); end if;
  -----------------------------------------------------------------------------
  -- Text Message
  -----------------------------------------------------------------------------
  if (c_len <= 4000 ) then
   l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>c_len, text_vc=>data_in, text_lob=>null ) ;
  else
   l_message := sys.aq$_jms_text_message( header=>null/*sys.aq$_jms_header*/, text_len=>c_len, text_vc=>null, text_lob=>data_in ) ;
  end if;
  l_message.set_userid (c_user ) ;
  l_message.set_string_property ('&&ofsx_prop_app', app_nm_in ) ;
  l_message.set_int_property    ('&&ofsx_prop_suc', is_success_in ) ;
  -----------------------------------------------------------------------------
  -- Enqueue. Autonomous transaction.
  -----------------------------------------------------------------------------
  ofsx_utl.enqueue (
    text_msg_in       => l_message,
    return_out        => return_out,
    message_out       => message_out,
    msg_id_out        => l_message_handle,
    queue_name_in     => '&&ofsx_text_response_queue',
    correlation_id_io => correlation_id_io ) ; if c_dbg then pdbg_('ofsx_utl.do_ack(app='||app_nm_in||',cid='||correlation_id_io||',msg='||data_in||',q$=&&ofsx_text_response_queue) enq.msgid='||l_message_handle); end if;
  -----------------------------------------------------------------------------
  if c_dbg then pdbg_('finish ofsx_utl.do_ack(app='||app_nm_in||',cid='||correlation_id_io||',msg='||data_in||',q$=&&ofsx_text_response_queue)'); end if;
  -----------------------------------------------------------------------------
 exception when others then
  message_out := 'ofsx_utl.do_ack(app='||app_nm_in||',cid='||correlation_id_io||',msg='||data_in||') prob: '||dbms_utility.format_error_stack || '@' || dbms_utility.format_call_stack;
  return_out := &&no_;
  perr_(message_out);
 end do_ack ;
 ------------------------------------------------------------------------------

 -------------------------------------------------------------------------------
 function get_version return varchar2
 is
  c_ver  constant varchar2(256) := '&&version_';
 begin
  return (c_ver ) ;
 end get_version;
 procedure pversion
 is
  l_ver varchar2(512) ;
 begin
  l_ver := get_version ;
  dbms_output.put_line( l_ver ) ;
 end pversion ;
 -------------------------------------------------------------------------------

end ofsx_utl;
/
set termout on
show errors package body &&ofsx_schema..ofsx_utl
