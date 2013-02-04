package com.wcrl.web.cml.client.loginService;

import java.util.Map;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("forgotPasswordService")
public interface ForgotPasswordService extends RemoteService {
	public static class Util {

		public static ForgotPasswordServiceAsync getInstance() {

			return GWT.create(ForgotPasswordService.class);
		}
	}

	public int sendEmail(Map<String, String> formData);
	
}
