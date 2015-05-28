package com.wcrl.web.cml.client.data.filesService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public interface GetDataFileDetailsServiceAsync 
{
	//public void getJobDetails(String fileName, String userName, String projectName, AsyncCallback<JobItem> callback);
	public void getDataFileDetails(DataFileItem item, AsyncCallback<DataFileItem> callback);	
}

