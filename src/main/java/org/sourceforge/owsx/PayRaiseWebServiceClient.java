package org.sourceforge.owsx;

/**
 * Make SOAP call to ORAWSV/OWSX/OWSX_UTL/PAY_RAISE.
 *
 */
public interface PayRaiseWebServiceClient {

	static final String DEFAULT_USER_AGENT = "Mozilla/4.0";
	
	void send(long curr_sal, double percent_increase) throws Exception;
	String get(long curr_sal, double percent_increase) throws Exception;

}