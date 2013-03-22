package com.wcrl.web.cml.client.loginService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface UserAvailabilityServiceAsync {

	public void checkUserAvailability(String username, AsyncCallback<Integer> callback);
	public void checkUserEmail(String email, AsyncCallback<Integer> callback);
}
