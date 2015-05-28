package com.wcrl.web.cml.client.data.filesService;

import java.util.List;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public interface GetDataFilesPageServiceAsync 
{
	public void getPage(int start, int length, boolean ascend, String user, String project, int tab, AsyncCallback<List<DataFileItem>> callback);
	public void getFilesNumber(AsyncCallback<Integer> callback);
}

