package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.account.User;

@RemoteServiceRelativePath("saveandDownloadUserListFileService")
public interface SaveandDownloadUserListFileService extends RemoteService {

	public static class Util {

		public static SaveandDownloadUserListFileServiceAsync getInstance() {

			return GWT.create(SaveandDownloadUserListFileService.class);
		}
	}
	
	public boolean saveandDownloadUserListFile(ArrayList<User> users);

}
