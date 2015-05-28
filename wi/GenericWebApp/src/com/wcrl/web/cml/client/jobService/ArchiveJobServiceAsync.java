package com.wcrl.web.cml.client.jobService;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface ArchiveJobServiceAsync 
{
	public void archiveJob(JobItem jobItem, AsyncCallback<JobItem> callback);
}
