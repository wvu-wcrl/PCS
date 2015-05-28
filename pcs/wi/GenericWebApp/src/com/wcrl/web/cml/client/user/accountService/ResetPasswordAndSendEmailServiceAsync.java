package com.wcrl.web.cml.client.user.accountService;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface ResetPasswordAndSendEmailServiceAsync 
{
	public void resetAndSendEmail(ArrayList<Integer> userIds, AsyncCallback<Boolean> resetSendEmailCallback);
}
