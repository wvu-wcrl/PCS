package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("resumeJobsService")
public interface ResumeJobsService extends RemoteService {

	public static class Util {

		public static ResumeJobsServiceAsync getInstance() {

			return GWT.create(ResumeJobsService.class);
		} 
	}	
	public List<JobItem> resumeJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab);
}
