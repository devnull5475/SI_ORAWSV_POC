package org.sourceforge.owsx;

public interface PayRaiseWebServiceClient {

	static final String DEFAULT_USER_AGENT = "Mozilla/4.0";
	
	void send(long curr_sal, double percent_increase) throws Exception;
	String get(long curr_sal, double percent_increase) throws Exception;

}