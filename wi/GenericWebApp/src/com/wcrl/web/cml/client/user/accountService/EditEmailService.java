package com.wcrl.web.cml.client.user.accountService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("editEmailService")
public interface EditEmailService extends RemoteService {

	public static class Util {

		public static EditEmailServiceAsync getInstance() {

			return GWT.create(EditEmailService.class);
		}
	}
	public boolean editEmail(int userId, String secondaryEmail);
}
