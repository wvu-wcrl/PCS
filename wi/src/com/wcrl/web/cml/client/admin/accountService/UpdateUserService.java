package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.account.User;

@RemoteServiceRelativePath("updateUserService")
public interface UpdateUserService extends RemoteService {

	public static class Util {

		public static UpdateUserServiceAsync getInstance() {

			return GWT.create(UpdateUserService.class);
		}
	}
	
	public int updateUserStatus(int userId, int status, String username, String primaryEmail);	
	public int updateFirstName(int userId, String firstName);
	public int updateLastName(int userId, String lastName);
	public int updateOrganization(int userId, String organization);
	public int updateJobTitle(int userId, String jobTitle);
	public int updateCountry(int userId, String country);
	public double updateQuota(int userId, User user, double newQuota);
}
