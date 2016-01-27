package com.googlecode.mgwt.examples.showcase.client.activities.elements.service;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;


public interface UserValidationServiceAsync {

	public void validateUser(String userName, String password, AsyncCallback<User> loginCallback);
	public void clearSession(AsyncCallback<Boolean> sessionCallback);
	public void validateSession(String username, AsyncCallback<String> validateSessionCallback);
	public void ckLogin(String username, String password, AsyncCallback<User> ckLoginCallback);
}
