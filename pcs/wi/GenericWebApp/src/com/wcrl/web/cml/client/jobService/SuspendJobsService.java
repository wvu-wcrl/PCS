package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("suspendJobsService")
public interface SuspendJobsService extends RemoteService {

	public static class Util {

		public static SuspendJobsServiceAsync getInstance() {

			return GWT.create(SuspendJobsService.class);
		} 
	}	
	public List<JobItem> suspendJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab);
}
