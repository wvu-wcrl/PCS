package com.wcrl.web.cml.client.loginService;

import java.util.Map;
import com.google.gwt.user.client.rpc.AsyncCallback;

public interface RegisterServiceAsync {

	public void register(Map<String, String> formData, String challenge, String response, AsyncCallback<Integer> callback);
	

}
