package com.wcrl.web.cml.client.data.filesService;

import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

@RemoteServiceRelativePath("getDataFilesPage")
public interface GetDataFilesPageService extends RemoteService {

	public static class Util {

		public static GetDataFilesPageServiceAsync getInstance() {

			return GWT.create(GetDataFilesPageService.class);
		}
	}
	
	public List<DataFileItem> getPage(int start, int length, boolean ascend, String user, String project, int tab);
	public int getFilesNumber();
}

