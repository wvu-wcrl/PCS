package com.googlecode.mgwt.examples.showcase.client.custom.jobs.service;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobItem;

public interface GetJobDetailsServiceAsync 
{
	public void getJobDetails(JobItem item, int from, AsyncCallback<JobItem> callback);	
}

