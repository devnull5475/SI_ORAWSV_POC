# OWsX: Oracle Web service Example

###Proof-of-concept example: ORAWSV & Spring Integration

This project is a proof-of-concept example or template for the following
SOA, web service scenario:

####Server
* **PL/SQL**: Domain business rules & logic written in PL/SQL, `OWSX.OWSX_UTL.PAY_RAISE`.
* [**ORAWSV**](http://docs.oracle.com/cd/E11882_01/appdev.112/e23094/xdb_web_services.htm#ADXDB3900): The `ORAWSV` servlet runs in Oracle's JVM (as if Oracle itself, rather than, say, Tomcat, were the servlet container).
* **SOAP Web Service**: PL/SQL is exposed as a SOAP web service by the `ORAWSV` servlet. URL: `https://${ORACLE_HOST}:${ORACLE_PORT}/orawsv/OWSX/OWSX_UTL/PAY_RAISE`

####Client
* **SOAP Client**: Use [Spring Integration](http://projects.spring.io/spring-integration/) to make SOAP call that invokes `OWSX_UTL.PAY_RAISE`.
* **RESTful Adapter**: Use Spring Integration to create a RESTful web service whose handler:
 (a) accepts a simple `GET` request,
 (b) delegates to SOAP client to make the SOAP call to `OWSX_UTL.PAY_RAISE`, &
 (c) hands back response.

###What you'll need

* An Oracle database to run PL/SQL. [Oracle XE](http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm) is a convenient choice.
* A [JDK](http://www.oracle.com/technetwork/java/javase/downloads/index.html) to compile client code. (Code has been compiled using Java 1.6.)
* [Apache Maven](http://maven.apache.org/index.html) for building project & managing dependencies.
* A servlet container, such as [Apache Tomcat](http://tomcat.apache.org/) to run client.

###HOWTO

####ORAWSV SOAP Service
1. Ensure Oracle available. If necessary, install [Oracle XE](http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm).
2. Install [Log4PLSQL](http://log4plsql.sourceforge.net/).
3. Build `OWSX` schema in Oracle. See `src/main/sql/patch.sql`. (NB: If Tomcat & Oracle are both to run on same host, then Tomcat port should be different from `ORAWSV` port.)
4. Use `admin/acl_info.sql` to ensure permissions right.
5. Test HTTP access to PL/SQL using `src/test/sql/ws.sql`.

####Java RESTful & SOAP Client
1. Ensure [Java](http://www.oracle.com/technetwork/java/javase/downloads/index.html), [Maven](http://maven.apache.org/index.html) &
   [Tomcat](http://tomcat.apache.org/) are installed. (NB: Again, if Tomcat & Oracle are both to run on same host, then Tomcat port should be different from `ORAWSV` port.)
2. Use `$ mvn compile test` & `mvn war:war` to build client.
3. Deploy resulting WAR file to Tomcat.
4. Test RESTful client using `http://${TOMCAT_HOST}:${TOMCAT_PORT}/owsx-${VERSION}/index.jsp`.

###Links

* [Getting Started with Oracle XML DB](http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb02rep.htm#i1011095)
* [Accessing PL/SQL Stored Procedures Using a Web Service](http://docs.oracle.com/cd/B28359_01/appdev.111/b28369/xdb_web_services.htm#CHDFGIBD)
* [Mark Drake's ORAWSV example](https://community.oracle.com/message/10283913#10283913)
* [Spring Integration](http://projects.spring.io/spring-integration/)
* [Apache HttpClient Tutorial](http://hc.apache.org/httpcomponents-client-ga/tutorial/html/index.html)
* [SoapUI](http://www.soapui.org/)
