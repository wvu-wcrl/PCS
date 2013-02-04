package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface SaveSubscribedProjectServiceAsync {

	public void saveProject(int projectId, int userId, int preferredProject, String username, String projectName, AsyncCallback<Integer> callback);
}
