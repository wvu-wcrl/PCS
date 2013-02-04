package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.account.User;

@RemoteServiceRelativePath("getUsersService")
public interface GetUsersService extends RemoteService 
{
	public static class Util 
	{
		public static GetUsersServiceAsync getInstance() 
		{
			return GWT.create(GetUsersService.class);
		}
	}	
	public ArrayList<User> getUsers();
}