package com.wcrl.web.cml.client.jobService;

import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface GetPageServiceAsync 
{
	public void getPage(int start, int length, boolean ascend, String statusDirectory, String user, String project, int tab, AsyncCallback<List<JobItem>> callback);
	public void getJobNumber(AsyncCallback<Integer> callback);
}

