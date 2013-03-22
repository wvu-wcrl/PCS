package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("clusterStatusService")
public interface ClusterStatusService extends RemoteService {

	public static class Util {

		public static ClusterStatusServiceAsync getInstance() {

			return GWT.create(ClusterStatusService.class);
		}
	}
	
	public String getClusterStatus(String queue);
}
