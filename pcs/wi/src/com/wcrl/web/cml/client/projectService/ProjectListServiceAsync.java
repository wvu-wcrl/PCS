package com.wcrl.web.cml.client.projectService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.projects.ProjectItem;

public interface ProjectListServiceAsync 
{
	public void getProjectList(AsyncCallback<ArrayList<ProjectItem>> callback);
}

