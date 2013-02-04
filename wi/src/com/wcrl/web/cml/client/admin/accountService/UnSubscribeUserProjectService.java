package com.wcrl.web.cml.client.admin.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("unSubscribeUserProject")
public interface UnSubscribeUserProjectService extends RemoteService {

	public static class Util {

		public static UnSubscribeUserProjectServiceAsync getInstance() {

			return GWT.create(UnSubscribeUserProjectService.class);
		}
	}
	public int unSubscribeProject(int userId, int programId);
}
