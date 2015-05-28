package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.jobs.JobItem;

public interface UploadedJobListServiceAsync 
{
	public void getUploadedJobList(String userName, int start, String statusDirectory, AsyncCallback<ArrayList<JobItem>> callback);
}

