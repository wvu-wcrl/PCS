package com.googlecode.mgwt.examples.showcase.client.activities.elements.service;


import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.AuthenticationException;
import com.googlecode.mgwt.examples.showcase.client.acctmgmt.User;

@RemoteServiceRelativePath("uservalidationservice")
public interface UserValidationService extends RemoteService {

	public static class Util {

		public static UserValidationServiceAsync getInstance() {

			return GWT.create(UserValidationService.class);
		}
	}
	
	public User validateUser(String userName, String password) throws AuthenticationException, Exception;
	public boolean clearSession();
	public String validateSession(String username);
	public User ckLogin(String username, String password);

}
