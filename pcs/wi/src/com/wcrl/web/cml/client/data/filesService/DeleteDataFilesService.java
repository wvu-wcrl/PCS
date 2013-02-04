package com.wcrl.web.cml.client.data.filesService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

@RemoteServiceRelativePath("deleteDataFilesService")
public interface DeleteDataFilesService extends RemoteService {

	public static class Util {

		public static DeleteDataFilesServiceAsync getInstance() {

			return GWT.create(DeleteDataFilesService.class);
		} 
	}	
	public List<DataFileItem> deleteDataFiles(ArrayList<DataFileItem> jobs, int start, int length, boolean ascend, int from, int tab);
}
