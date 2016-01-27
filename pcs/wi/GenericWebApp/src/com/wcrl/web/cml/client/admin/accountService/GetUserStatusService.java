package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("getUserStatusService")
public interface GetUserStatusService extends RemoteService 
{
	public static class Util 
	{
		public static GetUserStatusServiceAsync getInstance() 
		{
			return GWT.create(GetUserStatusService.class);
		}
	}	
	public int getUserStatus(int userId);
}