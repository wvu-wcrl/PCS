package com.wcrl.web.cml.client.admin.projectService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface DeleteProjectServiceAsync 
{
	public void deleteProject(int projectId, AsyncCallback<Integer> callback);
}
