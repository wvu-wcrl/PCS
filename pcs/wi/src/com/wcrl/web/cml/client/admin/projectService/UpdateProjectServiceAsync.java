package com.wcrl.web.cml.client.admin.projectService;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface UpdateProjectServiceAsync 
{	
	public void updateProjectName(int projectId, String newProjectName, AsyncCallback<int[]> updateProjectNameCallback);
	public void updateProjectDescription(int projectId, String description, AsyncCallback<int[]> updateProjectDescriptionCallback);
	public void updateProjectPath(int projectId, String path, AsyncCallback<int[]> updateProjectPathCallback);
	public void updateDataFile(int projectId, int required, AsyncCallback<int[]> updateProjectDataFile);
}
