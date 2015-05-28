package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("closeJobService")
public interface CloseJobService extends RemoteService {

	public static class Util {

		public static CloseJobServiceAsync getInstance() {

			return GWT.create(CloseJobService.class);
		}
	}
	//public JobItem jobStatus(JobItem item, String userName, int userId);	
	public JobItem closeJob(JobItem item);
}
