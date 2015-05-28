package com.wcrl.web.cml.client.data.filesService;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public interface DeleteDataFilesServiceAsync 
{
	public void deleteDataFiles(ArrayList<DataFileItem> jobs, int start, int length, boolean ascend, int from, int tab, AsyncCallback<List<DataFileItem>> callback);
}
