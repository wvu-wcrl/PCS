package com.wcrl.web.cml.client.user.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface EditEmailServiceAsync {

	public void editEmail(int userId, String secondaryEmail, AsyncCallback<Boolean> callback);
}
