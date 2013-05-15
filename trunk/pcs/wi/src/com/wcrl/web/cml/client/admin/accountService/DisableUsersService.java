package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("disableUsersService")
public interface DisableUsersService extends RemoteService {

	public static class Util {

		public static DisableUsersServiceAsync getInstance() {

			return GWT.create(DisableUsersService.class);
		}
	}
	
	public ArrayList<Integer> disableUsers(ArrayList<Integer> userIds);

}
