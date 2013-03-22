package com.wcrl.web.cml.client.admin.accountService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.account.User;


public interface SaveandDownloadUserListFileServiceAsync {

	public void saveandDownloadUserListFile(ArrayList<User> users, AsyncCallback<Boolean> callback);

}
