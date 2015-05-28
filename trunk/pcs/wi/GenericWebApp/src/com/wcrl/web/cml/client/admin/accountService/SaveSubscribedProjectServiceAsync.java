package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface SaveSubscribedProjectServiceAsync {

	public void saveProject(int projectId, int userId, int addProjectDirectory, String username, String projectName, int preferredProject, AsyncCallback<Integer> callback);
}
