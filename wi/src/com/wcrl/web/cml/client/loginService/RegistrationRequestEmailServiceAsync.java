package com.wcrl.web.cml.client.loginService;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface RegistrationRequestEmailServiceAsync 
{
	public void sendEmail(String firstName, String lastName, String primaryEmail, AsyncCallback<Boolean> sendEmailCallback);
}
