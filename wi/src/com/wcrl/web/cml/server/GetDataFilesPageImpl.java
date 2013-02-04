/*
 * File: UploadedJobListServiceImpl.java

Purpose: Java handler class to get a list of jobs of an user.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.data.filesService.GetDataFilesPageService;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public class GetDataFilesPageImpl extends RemoteServiceServlet implements GetDataFilesPageService 
{	
	private static final long serialVersionUID = 1L;
	private int totalFiles = 0;
	
	public List<DataFileItem> getPage(int start, int length, boolean ascend, String user, String project, int tab)
	{
		ResourceBundle constants = ResourceBundle.getBundle("Paths");
		String dirPath = constants.getString("path"); 
		String dataDir = constants.getString("Data");
		File aFile = new File(dirPath);
		DataFilesList files = new DataFilesList();
		ArrayList<DataFileItem> fileItems = files.filesList(aFile, start, length, ascend, "Date", user, project, tab, dataDir);
		this.totalFiles = files.getTotalFiles();
		System.out.println("GetPage start: " + start + " length: " + length);
		System.out.println("Dir path: " + dirPath + " Dir: " + aFile.getPath() + " " + aFile.getAbsolutePath());
	
		System.out.println("GetPage ItemCount: " + fileItems.size());
		return fileItems;	
	}	
	public int getFilesNumber()
	{		
		//return files.getTotalJobs();
		return this.totalFiles;
	}
}
