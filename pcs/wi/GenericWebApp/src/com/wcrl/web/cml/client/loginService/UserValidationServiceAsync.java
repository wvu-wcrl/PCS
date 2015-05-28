package com.wcrl.web.cml.client.loginService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.account.User;

public interface UserValidationServiceAsync {

	public void validateUserData(String userName, String password, boolean rememberMe, AsyncCallback<User> loginCallback);
	public void clearSession(AsyncCallback<Boolean> sessionCallback);
	public void validateSession(String username, AsyncCallback<String> validateSessionCallback);
	public void ckLogin(String username, String password, boolean reVisit, AsyncCallback<User> ckLoginCallback);
}
