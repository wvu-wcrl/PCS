package com.wcrl.web.cml.client.user.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface EditPasswordServiceAsync {

	//public void editPassword(int userId, String newPassword, AsyncCallback<Boolean> callback);
	//public void editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash, AsyncCallback<Boolean> callback);
	public void editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash, AsyncCallback<String> callback);
}
