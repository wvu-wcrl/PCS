package com.wcrl.web.cml.client.data.filesService;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

@RemoteServiceRelativePath("getDataFileDetails")
public interface GetDataFileDetailsService extends RemoteService {

	public static class Util {

		public static GetDataFileDetailsServiceAsync getInstance() {

			return GWT.create(GetDataFileDetailsService.class);
		}
	}
	
	public DataFileItem getDataFileDetails(DataFileItem item);
}

