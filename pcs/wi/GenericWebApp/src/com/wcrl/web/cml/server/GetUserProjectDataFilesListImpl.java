package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.ResourceBundle;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.datafiles.DataFileItem;
import com.wcrl.web.cml.client.jobService.GetUserProjectDataFilesListService;

public class GetUserProjectDataFilesListImpl  extends RemoteServiceServlet implements GetUserProjectDataFilesListService
{	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public ArrayList<DataFileItem> userProjectDataFilesList(String userName, String projectName) 
	{
		ResourceBundle constants = ResourceBundle.getBundle("Paths");
		String path = constants.getString("path"); 
		String projectsKey = constants.getString("projects");
		String dataDirKey = constants.getString("Data");
		
		String dirPath = path + userName + File.separator + projectsKey + File.separator + projectName + File.separator + dataDirKey;
		File dataDirectory = new File(dirPath);
		ArrayList<DataFileItem> dataFilesList = getProjectJobFiles(dataDirectory);
		return dataFilesList;
	}
	
	public ArrayList<DataFileItem> getProjectJobFiles(File dataDirectory)
	{
		System.out.println("User data files: " + dataDirectory.getPath());
		ArrayList<DataFileItem> dataFilesList = new ArrayList<DataFileItem>();
		if(dataDirectory != null)
		{
			if(dataDirectory.isDirectory())
			{
				File[] dataFiles = dataDirectory.listFiles();
				if(dataFiles != null)
				{
					int count = dataFiles.length;
					System.out.println("User data files count: " + count);
					for (int i = 0; i < count; i++)
					{
						File dataFile  = dataFiles[i];
						if(dataFile.isFile())
						{
							String fileName  = dataFile.getName();
							System.out.println("File: " + dataFile.getPath());
							DataFileItem item = new DataFileItem();
							item.setFileName(fileName);
							dataFilesList.add(item);
						}
					}
				}
				else
				{
					System.out.println(" [PROJECT DATA DIRECTORY ARE NOT CREATED]");
					Log.info(" [PROJECT DATA DIRECTORY ARE NOT CREATED]");
				}
			}
		}
		return dataFilesList;
	}
}