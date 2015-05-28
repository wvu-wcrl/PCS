package com.wcrl.web.cml.client.loginService;


import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.account.AuthenticationException;
import com.wcrl.web.cml.client.account.User;

@RemoteServiceRelativePath("uservalidationservice")
public interface UserValidationService extends RemoteService {

	public static class Util {

		public static UserValidationServiceAsync getInstance() {

			return GWT.create(UserValidationService.class);
		}
	}
	
	public User validateUserData(String userName, String password, boolean rememberMe) throws AuthenticationException, Exception;
	public boolean clearSession();
	public String validateSession(String username);
	public User ckLogin(String username, String password, boolean reVisit);

}
