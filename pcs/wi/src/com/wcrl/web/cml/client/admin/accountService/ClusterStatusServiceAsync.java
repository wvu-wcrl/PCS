package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface ClusterStatusServiceAsync 
{
	public void getClusterStatus(String queue, AsyncCallback<String> clusterStatusCallback);
}
