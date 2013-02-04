package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.account.User;

public interface UpdateUserServiceAsync 
{	
	public void updateUserStatus(int userId, int status, String username, String primaryEmail, AsyncCallback<Integer> updateUserStatusCallback);
	public void updateFirstName(int userId, String firstName, AsyncCallback<Integer> updateUserFirstNameCallback);
	public void updateLastName(int userId, String lastName, AsyncCallback<Integer> updateUserLastNameCallback);
	public void updateOrganization(int userId, String organization, AsyncCallback<Integer> updateUserOrganizationCallback);
	public void updateJobTitle(int userId, String jobTitle, AsyncCallback<Integer> updateUserJobTitleCallback);
	public void updateCountry(int userId, String country, AsyncCallback<Integer> updateUserCountryCallback);
	public void updateQuota(int userId, User user, double newQuota, AsyncCallback<Double> updateUserQuotaCallback);
}
