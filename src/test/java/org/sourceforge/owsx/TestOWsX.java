package org.sourceforge.owsx;

import static org.junit.Assert.assertNotNull;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.FileSystemXmlApplicationContext;

public class TestOWsX {

	private static final String PROD_CONFIG = "src/main/resources/META-INF/spring/owsx-config.xml";
    private static final String TEST_CONFIG = "src/test/resources/META-INF/spring/test-config.xml";
    private ApplicationContext test = null;
    private ApplicationContext prod = null;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
    }

    @AfterClass
    public static void tearDownAfterClass() throws Exception {
    }

    @Before
    public void setUp() throws Exception {
        this.test = new FileSystemXmlApplicationContext(TEST_CONFIG);
        assertNotNull("null==test.ac", this.test);
        this.prod = new FileSystemXmlApplicationContext(PROD_CONFIG);
        assertNotNull("null==prod.ac", this.prod);        
    }

    @After
    public void tearDown() throws Exception {
    }
    
    public void testSend01() throws Exception {
    	if (null==this.prod || null==this.test) {this.setUp();}
    	final PayRaiseWebServiceClient client = this.prod.getBean("caller", PayRaiseWebServiceClientImpl.class) ;
    	client.send(10000L, 0.10D);
    }

}
