package com.wcrl.web.cml.client.loginService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.seventhdawn.gwt.rcx.client.annotation.ClientProxySuperclass;
import com.seventhdawn.gwt.rcx.client.annotation.CustomSerializableRoots;
import com.seventhdawn.gwt.rpc.context.client.RPCContextServiceProxy;
import com.wcrl.web.cml.client.account.ClientContext;

@RemoteServiceRelativePath("registrationRequestEmailService")
@ClientProxySuperclass(RPCContextServiceProxy.class)
@CustomSerializableRoots({ClientContext.class})
public interface RegistrationRequestEmailService extends RemoteService {

	public static class Util 
	{
		public static RegistrationRequestEmailServiceAsync getInstance() 
		{
			return GWT.create(RegistrationRequestEmailService.class);
		}
	}
	
	public boolean sendEmail(String firstName, String lastName, String primaryEmail);

}
