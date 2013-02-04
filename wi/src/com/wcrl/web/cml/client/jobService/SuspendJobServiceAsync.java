package com.wcrl.web.cml.client.jobService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface SuspendJobServiceAsync 
{
	public void suspendJob(JobItem jobItem, AsyncCallback<JobItem> callback);
}
