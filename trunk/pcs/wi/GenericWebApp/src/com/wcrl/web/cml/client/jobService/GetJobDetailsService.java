package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("getJobDetails")

public interface GetJobDetailsService extends RemoteService {

	public static class Util {

		public static GetJobDetailsServiceAsync getInstance() {

			return GWT.create(GetJobDetailsService.class);
		}
	}
	
	//public JobItem getJobDetails(String fileName, String userName, String projectName);
	public JobItem getJobDetails(JobItem item, int from);
}

