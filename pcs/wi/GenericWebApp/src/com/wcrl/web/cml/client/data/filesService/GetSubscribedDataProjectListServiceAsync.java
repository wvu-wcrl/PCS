package com.wcrl.web.cml.client.data.filesService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.projects.ProjectItem;

public interface GetSubscribedDataProjectListServiceAsync 
{
	public void getSubscribedDataProjectList(int userId, AsyncCallback<ArrayList<ProjectItem>> callback);
}

