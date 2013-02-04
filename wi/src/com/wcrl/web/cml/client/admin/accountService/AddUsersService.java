package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("addUsersService")
public interface AddUsersService extends RemoteService {

	public static class Util {

		public static AddUsersServiceAsync getInstance() {

			return GWT.create(AddUsersService.class);
		}
	}
	
	public ArrayList<String> addUsers(int status, String[] usernames, String usertype, HashMap<Integer, String> subscribedProjectsMap);

}
