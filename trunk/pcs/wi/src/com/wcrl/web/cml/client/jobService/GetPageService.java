package com.wcrl.web.cml.client.jobService;

import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.jobs.JobItem;

@RemoteServiceRelativePath("getPage")

public interface GetPageService extends RemoteService {

	public static class Util {

		public static GetPageServiceAsync getInstance() {

			return GWT.create(GetPageService.class);
		}
	}
	
	public List<JobItem> getPage(int start, int length, boolean ascend, String statusDirectory, String user, String project, int tab);
	public int getJobNumber();
}

