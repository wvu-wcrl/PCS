package com.wcrl.web.cml.client.jobService;

import java.util.HashMap;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("getPreferredProjectService")
public interface GetPreferredProjectService extends RemoteService {

	public static class Util {

		public static GetPreferredProjectServiceAsync getInstance() {

			return GWT.create(GetPreferredProjectService.class);
		}
	}
	
	public HashMap<Integer, String> getPreferredProject(int userId);
}

