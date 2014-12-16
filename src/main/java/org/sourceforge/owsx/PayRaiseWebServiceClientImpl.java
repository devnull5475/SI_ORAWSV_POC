package org.sourceforge.owsx;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.http.HttpException;
import org.apache.http.HttpHost;
import org.apache.http.HttpRequest;
import org.apache.http.HttpRequestInterceptor;
import org.apache.http.auth.AuthScheme;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.AuthState;
import org.apache.http.auth.Credentials;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.AuthCache;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpClient;
import org.apache.http.client.protocol.ClientContext;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.BasicAuthCache;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.protocol.ExecutionContext;
import org.apache.http.protocol.HTTP;
import org.apache.http.protocol.HttpContext;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.ws.client.core.WebServiceTemplate;
import org.springframework.ws.transport.http.HttpComponentsMessageSender;

/**
 * 
 * @see HttpClient Tutorial: http://hc.apache.org/httpcomponents-client-ga/tutorial/html/index.html
 *
 */
public class PayRaiseWebServiceClientImpl implements PayRaiseWebServiceClient, InitializingBean {

	@Override
	public void send(final long curr_sal, final double percent_increase) throws Exception {
		final String xml = this.getSoapRequestXml_(curr_sal, percent_increase); System.err.println(xml);
		StreamSource source = new StreamSource(new StringReader(xml));
		StreamResult result = new StreamResult(System.out);		
		this.ws.sendSourceAndReceiveToResult(source, result);
		// TODO return new raised salary
	}

	private String getSoapRequestXml_(final long curr_sal, final double percent_increase) {
		return new StringBuilder("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
		        .append("<SOAP-ENV:Envelope ")
		        .append("xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" ")
                .append("xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" ")
        		.append("xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ")
        		.append("xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">")
        		.append("<SOAP-ENV:Body>")
                .append("<m:PAY_RAISEInput xmlns:m=\"http://xmlns.oracle.com/orawsv/OWSX/OWSX_UTL/PAY_RAISE\">")
                .append(this.getCurrentSalaryXml_(curr_sal))
                .append(this.getPercentIncreaseXml_(percent_increase))
                .append("<m:NEW_SALARY_OUT-NUMBER-OUT/>")
                .append("</m:PAY_RAISEInput>")
                .append("</SOAP-ENV:Body>")
                .append("</SOAP-ENV:Envelope>")
                .toString() ;
	}
	
	private String getCurrentSalaryXml_(final long curr_sal ) {
		return new StringBuilder("<m:CURRENT_SALARY_IN-NUMBER-IN>").append(curr_sal).append("</m:CURRENT_SALARY_IN-NUMBER-IN>").toString() ;
	}
	
	private String getPercentIncreaseXml_(final double percent_increase ) {
		return new StringBuilder("<m:PERCENT_CHANGE_IN-NUMBER-IN>").append(percent_increase).append("</m:PERCENT_CHANGE_IN-NUMBER-IN>").toString() ;
	}
		
	private WebServiceTemplate ws = null ;
	private Credentials credentials = null ;
	private String userAgent = DEFAULT_USER_AGENT ;
	
	public void setWebServiceTemplate(WebServiceTemplate t) {
		this.ws = t;
	}
	
	public WebServiceTemplate getWebServiceTemplate() {
		return this.ws;
	}
	
	public void setCredentials(Credentials c) {
		this.credentials = c;
	}
	
	public Credentials getCredentials() {
		return this.credentials;
	}
	
	public void setUserAgent(String u) {
		this.userAgent = u;
	}
	
	public String getUserAgent() {
		return this.userAgent;
	}
	
	public void afterPropertiesSet() throws Exception {
		if (null==this.ws) {throw new IllegalStateException("null==ws");}
		if (null==this.credentials) {throw new IllegalStateException("null==credentials");}
		CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
		AuthScope authScope = new AuthScope(AuthScope.ANY_HOST, AuthScope.ANY_PORT); //new UsernamePasswordCredentials(this.credentials.getUserPrincipal().getName(), this.credentials.getPassword()) ;
		credentialsProvider.setCredentials( authScope, this.credentials );
		org.apache.http.impl.client.CloseableHttpClient client =
		    org.apache.http.impl.client.HttpClients.custom()
				.addInterceptorFirst( new PayRaiseWebServiceClientImpl.ContentLengthHeaderRemover() )		    
				.addInterceptorFirst( new PayRaiseWebServiceClientImpl.PreemptiveAuthAdder() )				
				.setDefaultCredentialsProvider(credentialsProvider)
				.setUserAgent( this.userAgent )
				.build() ;
		HttpComponentsMessageSender ms = new HttpComponentsMessageSender( client ) ;		
		//ms.setAuthScope(authScope);
		//ms.setCredentials( this.credentials );
		this.ws.setMessageSender(ms);
	}
	
	private static class ContentLengthHeaderRemover implements HttpRequestInterceptor {
	    @Override
	    public void process(HttpRequest request, HttpContext context) throws HttpException, IOException {
	        request.removeHeaders(HTTP.CONTENT_LEN); // fighting org.apache.http.protocol.RequestContent's ProtocolException("Content-Length header already present");
	    }
	}
	
//	private static class PreemptiveAuthAdder implements HttpRequestInterceptor {
//		private Credentials credentials = null ;
//		public PreemptiveAuthAdder(final Credentials c) {
//			this.credentials = c ;
//		}
//	    @Override
//	    public void process(HttpRequest request, HttpContext context) throws HttpException, IOException {
//	        request.addHeader(new BasicScheme().authenticate(this.credentials, request) );
//	    }
//	}	
	
	private class PreemptiveAuthAdder implements HttpRequestInterceptor {

        public void process(final HttpRequest request, final HttpContext context) throws HttpException, IOException {
            
            AuthState authState = (AuthState) context.getAttribute( ClientContext.TARGET_AUTH_STATE ); log.debug(new StringBuilder("PreemptiveAuthAdder AuthScheme=").append(null!=authState ? authState.getAuthScheme() : null));
            
            // If no auth scheme avaialble yet, try to initialize it preemptively
            if (authState.getAuthScheme() == null) {
            	context.setAttribute("preemptive-auth", new BasicScheme());
                AuthScheme authScheme = (AuthScheme) context.getAttribute("preemptive-auth");
                CredentialsProvider credsProvider = (CredentialsProvider) context.getAttribute ( ClientContext.CREDS_PROVIDER);
                HttpHost targetHost = (HttpHost) context.getAttribute ( ExecutionContext.HTTP_TARGET_HOST);
                if (authScheme != null) {
                	log.debug("Add creds to AuthState");
                    Credentials creds = credsProvider.getCredentials (new AuthScope(targetHost.getHostName(), targetHost.getPort())); log.debug(new StringBuilder("u=").append(null!=creds ? creds.getUserPrincipal().getName() : null).append("; p=").append(null!=creds ? creds.getPassword() : null));
                    if (creds == null) {
                        throw new HttpException("No credentials for preemptive authentication");
                    }
                    final String up = new StringBuilder(credentials.getUserPrincipal().getName()).append(":").append(credentials.getPassword()).toString();
                    final UsernamePasswordCredentials upc = new UsernamePasswordCredentials(up);
                    authState.setCredentials(upc);                    
                    authState.setAuthScheme(authScheme);
                    AuthCache authCache = (AuthCache) context.getAttribute(ClientContext.AUTH_CACHE);
                    if (null==authCache) {
                    	authCache = new BasicAuthCache();                    	
                    }
                    authCache.put(targetHost, authScheme);
                    log.debug("Add AuthCache to context");
                    context.setAttribute(ClientContext.AUTH_CACHE, authCache);
                }
            }
            
        }
        
    }
	
	private static final Logger log = Logger.getLogger(PayRaiseWebServiceClientImpl.class);
	
	
	
}
