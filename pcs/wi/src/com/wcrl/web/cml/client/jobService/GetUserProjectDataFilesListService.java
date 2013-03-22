package com.wcrl.web.cml.client.jobService;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

@RemoteServiceRelativePath("getUserProjectDataFilesListService")
public interface GetUserProjectDataFilesListService extends RemoteService {

	public static class Util {

		public static GetUserProjectDataFilesListServiceAsync getInstance() {

			return GWT.create(GetUserProjectDataFilesListService.class);
		}
	}
	
	public ArrayList<DataFileItem> userProjectDataFilesList(String userName, String projectName);
}

