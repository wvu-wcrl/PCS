package com.wcrl.web.cml.client.jobService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface GetJobDetailsServiceAsync 
{
	//public void getJobDetails(String fileName, String userName, String projectName, AsyncCallback<JobItem> callback);
	public void getJobDetails(JobItem item, int from, AsyncCallback<JobItem> callback);	
}

