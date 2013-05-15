package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface DeleteUsersServiceAsync 
{
	public void deleteUsers(HashMap<Integer, String> users, AsyncCallback<ArrayList<Integer>> deleteUsersCallback);
}
