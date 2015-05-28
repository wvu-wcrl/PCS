package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface DeleteJobsServiceAsync 
{
	public void deleteJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab, AsyncCallback<List<JobItem>> callback);
}
