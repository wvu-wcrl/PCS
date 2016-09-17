package com.googlecode.mgwt.examples.showcase.client.custom.service;

import com.google.gwt.user.client.rpc.AsyncCallback;


public interface MasterKeyServiceAsync {

	public void verifyMasterKey(String adminProvidedExistingKey, AsyncCallback<Boolean> verifyKeyCallback);
	
}
