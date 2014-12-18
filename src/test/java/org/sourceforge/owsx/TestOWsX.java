package org.sourceforge.owsx;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

/**
 * Use JUnit tests to exercise ORAWSV POC examples.
 */
public class TestOWsX {

    private static final String _CONFIG = "src/test/resources/META-INF/spring/test-config.xml";
    private ApplicationContext ac = null;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
    }

    @AfterClass
    public static void tearDownAfterClass() throws Exception {
    }

    @Before()
    public void setUp() throws Exception {
        this.ac = new FileSystemXmlApplicationContext(_CONFIG);
        Assert.assertNotNull("null==ac", this.ac);       
    }

    @After
    public void tearDown() throws Exception {
    }
    
    public void testSend01() throws Exception {
        if (null==this.ac) {this.setUp();}
        final PayRaiseWebServiceClient caller = this.ac.getBean("soap.delegate", PayRaiseWebServiceClientImpl.class) ;
        caller.send(10000L, 0.10D);
    }

    public void testSend02() throws Exception {
        if (null==this.ac) {this.setUp();}
        final PayRaiseWebServiceClient caller = this.ac.getBean("soap.delegate", PayRaiseWebServiceClientImpl.class) ;
        caller.send(10000L, 0.20D);
    }

}
