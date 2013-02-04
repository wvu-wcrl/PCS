package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.account.User;


public interface GetUsersServiceAsync 
{
	public void getUsers(AsyncCallback<ArrayList<User>> getUsersCallback);
}
