package com.googlecode.mgwt.examples.showcase.client.custom.service;


import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;

@RemoteServiceRelativePath("masterkeyservice")
public interface MasterKeyService extends RemoteService {

	public static class Util {

		public static MasterKeyServiceAsync getInstance() {

			return GWT.create(MasterKeyService.class);
		}
	}
	
	public boolean verifyMasterKey(String adminProvidedExistingKey);

}
