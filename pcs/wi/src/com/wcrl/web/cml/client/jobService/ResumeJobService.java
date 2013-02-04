package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("resumeJobService")
public interface ResumeJobService extends RemoteService {

	public static class Util {

		public static ResumeJobServiceAsync getInstance() {

			return GWT.create(ResumeJobService.class);
		} 
	}	
	public JobItem resumeJob(JobItem jobItem);
}
