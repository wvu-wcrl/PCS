package com.wcrl.web.cml.client.jobService;

import java.util.HashMap;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface GetPreferredProjectServiceAsync 
{
	public void getPreferredProject(int userId, AsyncCallback<HashMap<Integer, String>> callback);
}

