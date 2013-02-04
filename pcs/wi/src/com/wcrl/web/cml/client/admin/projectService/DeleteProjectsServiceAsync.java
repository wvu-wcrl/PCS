package com.wcrl.web.cml.client.admin.projectService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface DeleteProjectsServiceAsync 
{
	public void deleteProjects(ArrayList<Integer> projectIds, AsyncCallback<ArrayList<Integer>> deleteProjectsCallback);
}
