package com.wcrl.web.cml.client.jobService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface JobStatusServiceAsync {

	//public void jobStatus(JobItem item, String userName, int userId, AsyncCallback<JobItem> callback);	
	public void jobStatus(JobItem item, String from, AsyncCallback<JobItem> callback);
}
