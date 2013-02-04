package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("archiveJobsService")
public interface ArchiveJobsService extends RemoteService {

	public static class Util {

		public static ArchiveJobsServiceAsync getInstance() {

			return GWT.create(ArchiveJobsService.class);
		} 
	}	
	public List<JobItem> archiveJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab);
}
