package com.googlecode.mgwt.examples.showcase.client.settings.service;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;


@RemoteServiceRelativePath("changePasswordService")
public interface ChangePasswordService extends RemoteService {

	public static class Util {

		public static ChangePasswordServiceAsync getInstance() {

			return GWT.create(ChangePasswordService.class);
		}
	}
	public String changePassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash);
}
