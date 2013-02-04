package com.wcrl.web.cml.client.loginService;

import java.util.Map;
import com.google.gwt.user.client.rpc.AsyncCallback;

public interface ForgotPasswordServiceAsync {

	public void sendEmail(Map<String, String> formData, AsyncCallback<Integer> callback);
	

}
