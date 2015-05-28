package com.wcrl.web.cml.client.loginService;

import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("registerService")
public interface RegisterService extends RemoteService {
	public static class Util {

		public static RegisterServiceAsync getInstance() {

			return GWT.create(RegisterService.class);
		}
	}

	public int register(Map<String, String> formData, String challenge, String response);
	
}
