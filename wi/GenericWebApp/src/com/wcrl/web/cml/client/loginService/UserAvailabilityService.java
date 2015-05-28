package com.wcrl.web.cml.client.loginService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("userAvailabilityService")
public interface UserAvailabilityService extends RemoteService {
	public static class Util {

		public static UserAvailabilityServiceAsync getInstance() {

			return GWT.create(UserAvailabilityService.class);
		}
	}
	public int checkUserAvailability(String username);
	public int checkUserEmail(String email);
}
