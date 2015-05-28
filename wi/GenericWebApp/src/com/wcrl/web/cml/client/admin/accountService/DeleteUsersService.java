package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;
import java.util.HashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("deleteUsersService")
public interface DeleteUsersService extends RemoteService {

	public static class Util {

		public static DeleteUsersServiceAsync getInstance() {

			return GWT.create(DeleteUsersService.class);
		}
	}
	
	public ArrayList<Integer> deleteUsers(HashMap<Integer, String> users);

}
