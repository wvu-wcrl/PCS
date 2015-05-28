package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("uploadedJobList")
public interface UploadedJobListService extends RemoteService 
{
	public static class Util 
	{
		public static UploadedJobListServiceAsync getInstance() 
		{
			return GWT.create(UploadedJobListService.class);
		}
	}	
	public ArrayList<JobItem> getUploadedJobList(String userName, int start, String statusDirectory);
}