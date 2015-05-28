package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.data.filesService.GetDataFileDetailsService;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public class GetDataFileDetailsImpl extends RemoteServiceServlet implements GetDataFileDetailsService
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");

	public DataFileItem getDataFileDetails(DataFileItem item)
	{
		item = getFileDetails(item);
		return item;		
	}

	public DataFileItem getFileDetails(DataFileItem item)
	{	
		String projectConstant = constants.getString("projects");
		String rootPath = constants.getString("path");
		String path1 = constants.getString("path1");
		String fileName = item.getFileName();
		String userName = item.getUsername();
		String projectName = item.getProjectName();
	
		String userProjectPath = userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		rootPath = rootPath + userProjectPath;
		String dir = constants.getString("Data"); 
		String filePath = rootPath + dir + File.separator + fileName;
		System.out.println("File path: " + filePath);
		File aFile = new File(filePath);
		
		if(aFile.exists())
		{
			String downloadFilePath = path1 + File.separator + userProjectPath + dir + File.separator + fileName;
			System.out.println("Link File path: " + downloadFilePath);
			Log.info("Link File path: " + downloadFilePath);
			item.setFileName(fileName);
			item.setPath(downloadFilePath);			
			item.setLastModified(aFile.lastModified());
		}
		item.setUsername(userName);
		item.setProjectName(projectName);
		return item;
	}	
}