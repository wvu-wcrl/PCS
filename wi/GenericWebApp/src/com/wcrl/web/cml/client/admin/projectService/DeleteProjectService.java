package com.wcrl.web.cml.client.admin.projectService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("deleteProjectService")
public interface DeleteProjectService extends RemoteService {

	public static class Util {

		public static DeleteProjectServiceAsync getInstance() {

			return GWT.create(DeleteProjectService.class);
		} 
	}	
	public int deleteProject(int projectId);
}
