package org.sourceforge.owsx;

import javax.servlet.http.HttpServletResponse;

public interface PayRaiseRESTClient {

	void getPayRaise(long currentSalary, double percentIncrease, HttpServletResponse response) throws Exception;

}