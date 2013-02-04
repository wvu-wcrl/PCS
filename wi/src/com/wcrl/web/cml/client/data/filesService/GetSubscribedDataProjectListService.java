package com.wcrl.web.cml.client.data.filesService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.projects.ProjectItem;

@RemoteServiceRelativePath("getSubscribedDataProjectList")
public interface GetSubscribedDataProjectListService extends RemoteService {

	public static class Util {

		public static GetSubscribedDataProjectListServiceAsync getInstance() {

			return GWT.create(GetSubscribedDataProjectListService.class);
		}
	}
	
	public ArrayList<ProjectItem> getSubscribedDataProjectList(int userId);
}

