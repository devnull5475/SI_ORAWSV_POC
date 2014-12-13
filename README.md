# OWsX: Oracle Web service Example

###Proof-of-concept example: Spring Integration, SOAP, & ORAWSV

This project is a proof-of-concept example or template for the following
SOA scenario:

* **PL/SQL**: Domain business rules & logic written in PL/SQL, `OWSX.OWSX_UTL.PAY_RAISE`.
* [**ORAWSV**](http://docs.oracle.com/cd/E11882_01/appdev.112/e23094/xdb_web_services.htm#ADXDB3900): The `ORAWSV` servlet runs in Oracle's JVM (as if Oracle itself, rather than, say, Tomcat, were the servlet container).
* **SOAP Web Service**: PL/SQL exposed as a SOAP web service by the `ORAWSV` servlet: `https://${ORACLE_HOST}:8080/orawsv/OWSX/OWSX_UTL/PAY_RAISE`
* **SOAP Client**: Use [Spring Integration](http://projects.spring.io/spring-integration/) to make SOAP call that invokes `owsx_utl.pay_raise`.
* **RESTful Adapter**: Use Spring Integration to create a RESTful web service whose handler makes the SOAP call to `owsx_utl.pay_raise`.

###Links

* [Getting Started with Oracle XML DB](http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb02rep.htm#i1011095)
* [Accessing PL/SQL Stored Procedures Using a Web Service](http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb_web_services.htm#CHDFGIBD)
* [Mark Drake's ORAWSV example](https://community.oracle.com/message/10283913#10283913)
* [Spring Integration](http://projects.spring.io/spring-integration/)
* [SoapUI](http://www.soapui.org/)
