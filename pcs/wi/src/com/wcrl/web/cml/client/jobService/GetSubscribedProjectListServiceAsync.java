package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.projects.ProjectItem;

public interface GetSubscribedProjectListServiceAsync 
{
	public void getSubscribedProjectList(int userId, AsyncCallback<ArrayList<ProjectItem>> callback);
}

