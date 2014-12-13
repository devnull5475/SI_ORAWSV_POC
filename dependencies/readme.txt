OFsX requires Oracle JDBC jars. It currently uses 11.2.0.3;
in the future it will use UCP from 12.1.0.1.

*******************************************************************************
* Compile, development time
* To install for local compiler, either:

1. Simply copy the following to your Maven repository:
 com/oracle/ojdbc6/11.2.0.3.0/
 com/oracle/ojdbc6/12.1.0.1/
 com/oracle/osgi.ojdbc6/11.2.0.3.0/
 com/oracle/osgi.ojdbc6.12c/12.1.0.1/

or

2. Use Maven to install:

$ # 11g
$ mvn install:install-file -Dfile=dependencies/com/oracle/ojdbc6/11.2.0.3.0/ojdbc6-11.2.0.3.0.jar -DgroupId=com.oracle -DartifactId=ojdbc6 -Dversion=11.2.0.3.0 -Dpackaging=jar
$ mvn install:install-file -Dfile=dependencies/com/oracle/osgi.ojdbc6/11.2.0.3/osgi.ojdbc6-11.2.0.3.jar -DgroupId=com.oracle -DartifactId=osgi.ojdbc6 -Dversion=11.2.0.3 -Dpackaging=jar

$ # UCP, 11g or 12c
$ mvn install:install-file -Dfile=dependencies/com/oracle/ojdbc6/12.1.0.1/ojdbc6-12.1.0.1.jar -DgroupId=com.oracle -DartifactId=ojdbc6 -Dversion=12.1.0.1 -Dpackaging=jar
$ mvn install:install-file -Dfile=dependencies/com/oracle/osgi.ojdbc6.12c/12.1.0.1/osgi.ojdbc6.12c-12.1.0.1.jar -DgroupId=com.oracle -DartifactId=osgi.ojdbc6.12c -Dversion=12.1.0.1 -Dpackaging=jar
*******************************************************************************

*******************************************************************************
* Runtime
* To install for Virgo runtime:

# 11g
$ cp dependencies/com/oracle/osgi.ojdbc6/11.2.0.3/osgi.ojdbc6-11.2.0.3.jar $VIRGO/repository/usr

# UCP, 11g or 12c
$ cp dependencies/com/oracle/osgi.ojdbc6.12c/12.1.0.1/osgi.ojdbc6.12c-12.1.0.1.jar $VIRGO/repository/usr
*******************************************************************************
