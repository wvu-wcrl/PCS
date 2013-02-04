package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("saveSubscribedProject")
public interface SaveSubscribedProjectService extends RemoteService {

	public static class Util {

		public static SaveSubscribedProjectServiceAsync getInstance() {

			return GWT.create(SaveSubscribedProjectService.class);
		}
	}
	public int saveProject(int projectId, int userId, int preferredProject, String username, String projectName);
}
