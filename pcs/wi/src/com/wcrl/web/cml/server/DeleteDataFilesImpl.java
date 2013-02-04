/*
 * File: DeleteAJobServiceImpl.java

Purpose: Java class to Delete a Job of an user from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.data.filesService.DeleteDataFilesService;
import com.wcrl.web.cml.client.datafiles.DataFileItem;

public class DeleteDataFilesImpl extends RemoteServiceServlet implements DeleteDataFilesService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String projectConstant = constants.getString("projects");
	
	public List<DataFileItem> deleteDataFiles(ArrayList<DataFileItem> files, int start, int length, boolean ascend, int from, int tab)
	{
		List<DataFileItem> filesList = null;
		int count = files.size();
		String fileName;
		String projectName = null;
		String userName = null;
			
		for(int index = 0; index < count; index++)
		{
			DataFileItem item = files.get(index);
			fileName = item.getFileName();
			projectName = item.getProjectName();
			userName = item.getUsername();
			
			String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
			
			String dir = constants.getString("Data");
			String filePath = rootPath + dir + File.separator + fileName;
			File file = new File(filePath);
			System.out.println("Data file to delete: " + file.getPath() + " Exists: " + file.exists());
			if(file.exists())
			{
				file.delete();
			}
		}
		
		if(from == 0)
		{
			GetDataFilesPageImpl getfiles = new GetDataFilesPageImpl();
			filesList = getfiles.getPage(start, start + length, ascend, userName, projectName, tab);
		}	
		return filesList;
	}	
}