package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("deleteJobsService")
public interface DeleteJobsService extends RemoteService {

	public static class Util {

		public static DeleteJobsServiceAsync getInstance() {

			return GWT.create(DeleteJobsService.class);
		} 
	}	
	public List<JobItem> deleteJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab);
}
