package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface AddUsersServiceAsync {

	public void addUsers(int status, String[] usernames, String usertype, HashMap<Integer, String> subscribedProjectsMap, AsyncCallback<ArrayList<String>> addUsersCallback);

}
