package com.wcrl.web.cml.client.user.accountService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.seventhdawn.gwt.rcx.client.annotation.ClientProxySuperclass;
import com.seventhdawn.gwt.rcx.client.annotation.CustomSerializableRoots;
import com.seventhdawn.gwt.rpc.context.client.RPCContextServiceProxy;
import com.wcrl.web.cml.client.account.ClientContext;

@RemoteServiceRelativePath("resetPasswordAndSendEmailService")
@ClientProxySuperclass(RPCContextServiceProxy.class)
@CustomSerializableRoots({ClientContext.class})
public interface ResetPasswordAndSendEmailService extends RemoteService {

	public static class Util {

		public static ResetPasswordAndSendEmailServiceAsync getInstance() {

			return GWT.create(ResetPasswordAndSendEmailService.class);
		}
	}
	
	public boolean resetAndSendEmail(ArrayList<Integer> userIds);

}
