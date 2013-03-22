/*
 * File: SuspendJobImpl.java

Purpose: Java class to Delete a Job of an user from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.jobService.ArchiveJobService;
import com.wcrl.web.cml.client.jobs.JobItem;

public class ArchiveJobImpl extends RemoteServiceServlet implements ArchiveJobService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String projectConstant = constants.getString("projects");

	public JobItem archiveJob(JobItem item)
	{	
		String statusDirectory = "JobOut";
				
		String fileName = item.getJobName();
		String projectName = item.getProjectName();
		String userName = item.getUsername();
					
		String userProjectPath = userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		ArchiveJobsImpl archive = new ArchiveJobsImpl();
		Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
		if(archive.checkAndMoveFile(statusDirectory, fileName, rootPath, userProjectPath))
		{				
			//String newPath = rootPath + constants.getString("Suspend") + File.separator;
			String archiveConstant = constants.getString("archive");
			String filePath = rootPath + archiveConstant + File.separator + fileName;
			String[] fileData = new String[2];
			fileData[0] = fileName;
			fileData[1] = filePath;
			outputFiles.put(1, fileData);
			
			//GetJobDetails jobDetails = new GetJobDetails();				
			//outputFiles = jobDetails.getOutputFiles(newPath, fileName, outputFiles);
			item.setStatus("Archived");
			//item.setOutputFiles(outputFiles);
		}
		System.out.println("Output files after suspension: " + item.getOutputFiles().size() + " Status: " + item.getStatus() + " Job: " + item);
		return item;
		
	}
}