package com.wcrl.web.cml.client.admin.projectService;

import java.util.Map;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("addProjectService")
public interface AddProjectService extends RemoteService {

	public static class Util {

		public static AddProjectServiceAsync getInstance() {

			return GWT.create(AddProjectService.class);
		}
	}
	
	public int addProject(Map<String, String> formData);

}
