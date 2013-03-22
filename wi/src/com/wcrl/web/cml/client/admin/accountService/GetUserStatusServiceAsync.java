package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface GetUserStatusServiceAsync 
{
	public void getUserStatus(int userId, AsyncCallback<Integer> getUserStatusCallback);
}
