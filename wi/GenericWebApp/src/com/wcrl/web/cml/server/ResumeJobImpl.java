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
import com.wcrl.web.cml.client.jobService.ResumeJobService;
import com.wcrl.web.cml.client.jobs.JobItem;

public class ResumeJobImpl extends RemoteServiceServlet implements ResumeJobService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String path1 = constants.getString("path1"); 
	private String projectConstant = constants.getString("projects");
	private String suspendConstant = constants.getString("Suspend");
	private String queueConstant = constants.getString("JobIn");;
	
	public JobItem resumeJob(JobItem item)
	{	
		//String rootPathForDownload = getServletContext().getRealPath(File.separator);
		String statusDirectory = suspendConstant;
		
		String fileName = item.getJobName();
		String projectName = item.getProjectName();
		String userName = item.getUsername();
					
		String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		//rootPathForDownload = rootPathForDownload + path1 + File.separator + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
		String pathForDownload = path1 + File.separator + userName + File.separator + projectConstant + File.separator + projectName + File.separator;	
		
		ResumeJobsImpl resume = new ResumeJobsImpl();
		Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
		//if(resume.checkAndMoveFile(statusDirectory, fileName, rootPath, rootPathForDownload))
		if(resume.checkAndMoveFile(statusDirectory, fileName, rootPath))
		{						
			String filePath = rootPath + queueConstant + File.separator + fileName;
			String newPath = rootPath + constants.getString("Figures") + File.separator;
			String[] fileData = new String[3];
			fileData[0] = fileName;			
			fileData[1] = pathForDownload + queueConstant + File.separator + fileName;
			fileData[2] = filePath;
			System.out.println("Path to download: " + fileData[1] + " " + pathForDownload);
			outputFiles.put(1, fileData);
			
			GetJobDetails jobDetails = new GetJobDetails();				
			outputFiles = jobDetails.getOutputFiles(newPath, fileName, outputFiles, pathForDownload);
			item.setStatus("Queued");
			item.setOutputFiles(outputFiles);
		}
		System.out.println("Output files after resume: " + item.getOutputFiles().size() + " Status: " + item.getStatus() + " Job: " + item);
		return item;
		
	}
}