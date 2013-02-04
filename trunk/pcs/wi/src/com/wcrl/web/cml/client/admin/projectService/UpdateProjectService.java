package com.wcrl.web.cml.client.admin.projectService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("updateProjectService")
public interface UpdateProjectService extends RemoteService {

	public static class Util {

		public static UpdateProjectServiceAsync getInstance() {

			return GWT.create(UpdateProjectService.class);
		}
	}
	
	public int[] updateProjectName(int projectId, String newProjectName);
	public int[] updateProjectDescription(int projectId, String description);
	public int[] updateProjectPath(int projectId, String path);
	public int[] updateDataFile(int projectId, int required);
}
