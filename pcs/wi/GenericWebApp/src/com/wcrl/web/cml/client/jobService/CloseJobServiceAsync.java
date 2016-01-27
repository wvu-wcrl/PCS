package com.wcrl.web.cml.client.jobService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface CloseJobServiceAsync 
{
	//public void jobStatus(JobItem item, String userName, int userId, AsyncCallback<JobItem> callback);	
	public void closeJob(JobItem item, AsyncCallback<JobItem> callback);
}
