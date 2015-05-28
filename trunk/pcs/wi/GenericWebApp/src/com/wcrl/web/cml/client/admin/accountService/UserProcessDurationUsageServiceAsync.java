package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface UserProcessDurationUsageServiceAsync 
{
	public void getUserUsage(int userId, AsyncCallback<Double> callback);
}
