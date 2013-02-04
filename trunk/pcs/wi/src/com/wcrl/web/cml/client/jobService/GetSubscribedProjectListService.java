package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.projects.ProjectItem;

@RemoteServiceRelativePath("getSubscribedProjectList")
public interface GetSubscribedProjectListService extends RemoteService {

	public static class Util {

		public static GetSubscribedProjectListServiceAsync getInstance() {

			return GWT.create(GetSubscribedProjectListService.class);
		}
	}
	
	public ArrayList<ProjectItem> getSubscribedProjectList(int userId);
}

