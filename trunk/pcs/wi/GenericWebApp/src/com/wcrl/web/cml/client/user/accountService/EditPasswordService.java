package com.wcrl.web.cml.client.user.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;


@RemoteServiceRelativePath("editPasswordService")
public interface EditPasswordService extends RemoteService {

	public static class Util {

		public static EditPasswordServiceAsync getInstance() {

			return GWT.create(EditPasswordService.class);
		}
	}
	//public boolean editPassword(int userId, String newPassword);
	//public boolean editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash);
	public String editPassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash);
}
