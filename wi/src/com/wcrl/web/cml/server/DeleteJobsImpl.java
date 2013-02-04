/*
 * File: DeleteAJobServiceImpl.java

Purpose: Java class to Delete a Job of an user from Database.
**********************************************************/
package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;
import java.util.Map.Entry;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.wcrl.web.cml.client.jobService.DeleteJobsService;
import com.wcrl.web.cml.client.jobs.JobItem;

public class DeleteJobsImpl extends RemoteServiceServlet implements DeleteJobsService 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private ResourceBundle constants = ResourceBundle.getBundle("Paths");
	private String path = constants.getString("path"); 
	private String path1 = constants.getString("path1"); 
	private String projectConstant = constants.getString("projects");
	//private String rootPathForDownload = getServletContext().getRealPath(File.separator);
	
	public List<JobItem> deleteJobs(ArrayList<JobItem> jobs, int start, int length, boolean ascend, String status, int from, int tab)
	{
		String rootPathForDownload = getServletContext().getRealPath(File.separator);
		List<JobItem> jobList = null;
		int count = jobs.size();
		String fileName;
		String projectName = null;
		String userName = null;
		
		String[] statusDirectory = new String[6];
		statusDirectory[0] = "JobIn";
		statusDirectory[1] = "JobRunning";
		statusDirectory[2] = "JobOut";
		statusDirectory[3] = "archive";
		statusDirectory[4] = "Suspend";
		statusDirectory[5] = "JobFailed";
		
		for(int index = 0; index < count; index++)
		{
			JobItem item = jobs.get(index);
			fileName = item.getJobName();
			projectName = item.getProjectName();
			userName = item.getUsername();
			
			String rootPath = path + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
			rootPathForDownload = rootPathForDownload + path1 + File.separator + userName + File.separator + projectConstant + File.separator + projectName + File.separator;
			int directoryCount = statusDirectory.length;
			for(int i = 0; i < directoryCount; i++)
			{
				String dir = constants.getString(statusDirectory[i]);
				String filePath = rootPath + dir + File.separator + fileName;
				File file = new File(filePath);
				System.out.println("Job file to delete: " + file.getPath() + " Exists: " + file.exists());
				if(file.exists())
				{
					FileOperations fileOperations = new FileOperations();
					file.delete();
					GetJobDetails jobDetails = new GetJobDetails();
					Map<Integer, String[]> outputFiles = new HashMap<Integer, String[]>();
					String filesPath = rootPath + constants.getString("Figures") + File.separator;
					outputFiles = jobDetails.getOutputFiles(filesPath, fileName, outputFiles, rootPathForDownload);
					
					if(outputFiles != null)
					{
						System.out.println("OutputFiles size: " + outputFiles.size());
						if(outputFiles.size() > 0)
						{
							Set<Entry<Integer, String[]>> entries = outputFiles.entrySet();
							for(Entry<Integer, String[]> entry : entries)
							{
								String[] fileData = entry.getValue();
							    System.out.println("OutputFiles: " + fileData[1]);
							    File outputFile = new File(fileData[1]);
							    if(outputFile.exists())
							    {
							    	fileOperations.removeFile(outputFile);
							    }
							}
						}
					}
					
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
}
