/*
 * File: SuspendJobImpl.java

Purpose: Java class to Delete a Job of an user from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.jobService.SuspendJobsService;
import com.wcrl.web.cml.client.jobs.JobItem;

public class SuspendJobsImpl extends RemoteServiceServlet implements SuspendJobsService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String projectConstant = constants.getString("projects");

	public List<JobItem> suspendJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab)
	{		
		List<JobItem> jobList = null;
		int count = jobs.size();
		String fileName;
		String projectName = null;
		String userName = null;
		System.out.println("Status: " + status);
		
		String[] statusDirectory = new String[2];
		statusDirectory[0] = "JobIn";
		statusDirectory[1] = "JobRunning";	
		
		for(int index = 0; index < count; index++)
		{
			JobItem item = jobs.get(index);
			fileName = item.getJobName();
			projectName = item.getProjectName();
			userName = item.getUsername();
						
			String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
			
			for(int i = 0; i < 2; i++)
			{
				if(checkAndMoveFile(statusDirectory[i], fileName, rootPath))
				{
					break;
				}
			}
			
		}
		if(from == 0)
		{
			GetPageImpl getJobs = new GetPageImpl();
			jobList = getJobs.getPage(start, start + length, ascend, status, userName, projectName, tab);
		}	
		return jobList;
	}
	
	public boolean checkAndMoveFile(String statusDirectory, String fileName, String rootPath)
	{		
		//GetJobDetails jobDetails = new GetJobDetails();
		//Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
		String dir = constants.getString(statusDirectory);
		String filePath = rootPath + dir + File.separator + fileName;
		//String filesPath = rootPath + constants.getString("Figures") + File.separator;
		//outputFiles = jobDetails.getOutputFiles(filesPath, fileName, outputFiles);
		
		File jobFile = new File(filePath);
		boolean flag = jobFile.exists();
		if(flag)
		{
			// Move job file to Suspended directory
			String destinationPath = rootPath + constants.getString("Suspend") + File.separator + fileName;
			System.out.println("To move File path: " + filePath);
			FileOperations fileOperations = new FileOperations();
			fileOperations.copyFile(filePath, destinationPath);
			fileOperations.removeFile(jobFile);
			
			/*// Other output files
			if(outputFiles != null)
			{
				if(outputFiles.size() > 0)
				{
					Set<Entry<Integer, String[]>> entries = outputFiles.entrySet();
					for(Entry<Integer, String[]> entry : entries)
					{
						String[] fileData = entry.getValue();
					    System.out.println("OutputFiles: " + fileData[1]);
					    File file = new File(fileData[1]);
					    if(file.exists())
					    {
					    	destinationPath = rootPath + constants.getString("Suspend") + File.separator + fileData[0];
					    	fileOperations.copyFile(fileData[1], destinationPath);
							fileOperations.removeFile(file);
					    }				    
					}
				}
			}*/			
		}	
		return flag;
	}
}