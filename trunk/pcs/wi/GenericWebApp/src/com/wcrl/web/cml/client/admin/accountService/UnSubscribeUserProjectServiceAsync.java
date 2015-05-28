package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface UnSubscribeUserProjectServiceAsync {

	public void unSubscribeProject(int userId, int programId, AsyncCallback<Integer> callback);
}
