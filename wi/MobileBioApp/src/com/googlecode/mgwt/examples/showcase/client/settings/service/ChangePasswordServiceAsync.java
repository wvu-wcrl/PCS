package com.googlecode.mgwt.examples.showcase.client.settings.service;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface ChangePasswordServiceAsync {

	public void changePassword(int userId, String newPassword, String userEnteredCurrentPasswd, String currentPasswordHash, AsyncCallback<String> callback);
}
