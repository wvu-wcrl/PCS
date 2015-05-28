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
import com.wcrl.web.cml.client.jobService.SuspendJobService;
import com.wcrl.web.cml.client.jobs.JobItem;

public class SuspendJobImpl extends RemoteServiceServlet implements SuspendJobService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String path1 = constants.getString("path1");
	private String projectConstant = constants.getString("projects");

	public JobItem suspendJob(JobItem item)
	{	
		//String rootPathForDownload = getServletContext().getRealPath(File.separator);
		String[] statusDirectory = new String[2];
		statusDirectory[0] = "JobIn";
		statusDirectory[1] = "JobRunning";
		
		String fileName = item.getJobName();
		String projectName = item.getProjectName();
		String userName = item.getUsername();
					
		String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		//rootPathForDownload = rootPathForDownload + path1 + File.separator + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		String pathForDownload = path1 + File.separator + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		SuspendJobsImpl suspend = new SuspendJobsImpl();
		Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
		for(int i = 0; i < 2; i++)
		{						
			if(suspend.checkAndMoveFile(statusDirectory[i], fileName, rootPath))
			{				
				//String newPath = rootPath + constants.getString("Suspend") + File.separator;
				String suspendConstant = constants.getString("Suspend");
				String newPath = rootPath + constants.getString("Figures") + File.separator;
				String filePath = rootPath + suspendConstant + File.separator + fileName;
				String[] fileData = new String[3];
				fileData[0] = fileName;
				fileData[1] = pathForDownload + suspendConstant + File.separator + fileName;
				fileData[2] = filePath;
				outputFiles.put(1, fileData);
				
				GetJobDetails jobDetails = new GetJobDetails();				
				outputFiles = jobDetails.getOutputFiles(newPath, fileName, outputFiles, pathForDownload);
				item.setStatus(suspendConstant);
				item.setOutputFiles(outputFiles);
				break;
			}
		}
		System.out.println("Output files after suspension: " + item.getOutputFiles().size() + " Status: " + item.getStatus() + " Job: " + item);
		return item;
		
	}
}