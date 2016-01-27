package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface DisableUsersServiceAsync 
{
	public void disableUsers(ArrayList<Integer> userIds, AsyncCallback<ArrayList<Integer>> deleteUsersCallback);
}
