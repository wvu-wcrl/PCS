/*
 * File: UserProcessDurationUsageImpl

Purpose: Java class to get a user usage from the database.
**********************************************************/
package com.wcrl.web.cml.server;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.admin.accountService.UserProcessDurationUsageService;

public class UserProcessDurationUsageImpl extends RemoteServiceServlet implements UserProcessDurationUsageService
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public double getUserUsage(int userId) 
	{
		double totalUsage = 0;
		UserProcessDurationUsage userUsage = new UserProcessDurationUsage();
		totalUsage = userUsage.getUserUsage(userId);		
		return totalUsage;
	}
}
