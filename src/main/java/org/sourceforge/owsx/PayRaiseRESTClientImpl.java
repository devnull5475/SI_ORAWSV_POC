package org.sourceforge.owsx;

import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class PayRaiseRESTClientImpl implements InitializingBean {
	
	public void getPayRaise(@RequestParam("currentSalary") final long currentSalary, @RequestParam("percentIncrease") final double percentIncrease, HttpServletResponse response) throws Exception {
		log.debug(new StringBuilder("currentSalary=").append(currentSalary).append(", percentIncrease=").append(percentIncrease));
	}
			
	@Autowired
	private PayRaiseWebServiceClient orawsv_client = null;
	
	public void setPayRaiseWebServiceClient(PayRaiseWebServiceClient c) {
		this.orawsv_client = c;
	}
	public PayRaiseWebServiceClient getPayRaiseWebServiceClient() {
		return this.orawsv_client ;
	}
	
	private static final Logger log = Logger.getLogger(PayRaiseRESTClientImpl.class);

	@Override
	public void afterPropertiesSet() throws Exception {
		if (null==this.orawsv_client) {throw new IllegalStateException("null==this.orawsv_client");}
		
	}

}
