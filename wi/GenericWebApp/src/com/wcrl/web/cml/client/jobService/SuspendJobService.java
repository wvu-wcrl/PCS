package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("suspendJobService")
public interface SuspendJobService extends RemoteService {

	public static class Util {

		public static SuspendJobServiceAsync getInstance() {

			return GWT.create(SuspendJobService.class);
		} 
	}	
	public JobItem suspendJob(JobItem jobItem);
}
