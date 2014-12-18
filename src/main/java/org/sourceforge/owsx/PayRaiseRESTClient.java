package org.sourceforge.owsx;

import javax.servlet.http.HttpServletResponse;

/**
 * Receive REST GET and delegate it to SOAP client.
 *
 */
public interface PayRaiseRESTClient {

	void getPayRaise(long currentSalary, double percentIncrease, HttpServletResponse response) throws Exception;

}