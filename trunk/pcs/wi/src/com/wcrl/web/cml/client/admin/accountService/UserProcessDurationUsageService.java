package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("userProcessDurationUsageService")
public interface UserProcessDurationUsageService extends RemoteService {

	public static class Util {

		public static UserProcessDurationUsageServiceAsync getInstance() {

			return GWT.create(UserProcessDurationUsageService.class);
		}
	}
	public double getUserUsage(int userId);
}
