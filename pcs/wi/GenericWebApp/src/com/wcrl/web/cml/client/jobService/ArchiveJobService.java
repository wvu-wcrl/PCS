package com.wcrl.web.cml.client.jobService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("archiveJobService")
public interface ArchiveJobService extends RemoteService {

	public static class Util {

		public static ArchiveJobServiceAsync getInstance() {

			return GWT.create(ArchiveJobService.class);
		} 
	}	
	public JobItem archiveJob(JobItem jobItem);
}
