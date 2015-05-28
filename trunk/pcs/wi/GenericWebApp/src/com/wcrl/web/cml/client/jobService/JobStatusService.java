package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("jobStatusService")
public interface JobStatusService extends RemoteService {

	public static class Util {

		public static JobStatusServiceAsync getInstance() {

			return GWT.create(JobStatusService.class);
		}
	}
	//public JobItem jobStatus(JobItem item, String userName, int userId);	
	public JobItem jobStatus(JobItem item, String from);
}
