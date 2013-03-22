package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public interface GetUserProjectDataFilesListServiceAsync 
{
	public void userProjectDataFilesList(String userName, String projectName, AsyncCallback<ArrayList<DataFileItem>> callback);
}

