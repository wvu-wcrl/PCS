package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.ResourceBundle;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLStructure;
import com.wcrl.web.cml.client.jobs.JobItem;

public class FilesList 
{		
	private int totalJobs;
	
	public int getTotalJobs() 
	{
		return totalJobs;
	}
	
	public void setTotalJobs(int totalJobs) 
	{
		this.totalJobs = totalJobs;
	}
	
	public ArrayList<JobItem> sort(ArrayList<JobItem> fileItems, final boolean ascend, String column)
	{		
		//Sort files by Filename
		if(column.equalsIgnoreCase("Name"))
		{
			System.out.println("Column to sort: " + column);
			Collections.sort(fileItems, new Comparator<JobItem>() 
			{
				public int compare(JobItem o1, JobItem o2)
				{
					String a = o1.getJobName();
					String b = o2.getJobName();
					
					return a.compareTo(b);					
				}
			});
		}
		else if(column.equalsIgnoreCase("Date"))
		{
			System.out.println("Column to sort: " + column);
			Collections.sort(fileItems, new Comparator<JobItem>() 
			{
				public int compare(JobItem o1, JobItem o2)
				{
					Long a = o1.getLastModified();
					Long b = o2.getLastModified();
					
					if(ascend)
					{
						return a.compareTo(b);
					}
					else
					{
						return b.compareTo(a);
					}					
					/*if(a > b)
						return 1;
					else if(a < b)
						return -1;
					else
						return 0;*/
				}
			});
		}
		return fileItems;
	}
	
	public ArrayList<JobItem> filesList(File aFile, String status, int start, int length, boolean ascend, String column, String userName, String projectName, int tab)
	{  
		ArrayList<String> statusDirectory = new ArrayList<String>();
		System.out.println("FileList status: " + status);
		
		//String statusDirectory = "";
		if(status.equals("Queued"))
		{
			statusDirectory.add("JobIn");
			//statusDirectory = "JobIn";
		}
		else if(status.equals("Running"))
		{	
			statusDirectory.add("JobRunning");
			//statusDirectory = "JobRunning";
		}
		else if(status.equals("Done"))
		{
			statusDirectory.add("JobOut");
			//statusDirectory = "JobOut";
		}
		else if(status.equals("Archive"))
		{
			statusDirectory.add("archive");
			//statusDirectory = "archive";
		}
		else if(status.equals("Suspended"))
		{
			statusDirectory.add("Suspend");
			//statusDirectory = "Suspended";
		}
		else if(status.equals("Failed"))
		{
			statusDirectory.add("JobFailed");
			//statusDirectory = "JobFailed";
		}
		else
		{
			statusDirectory.add("JobIn");
			statusDirectory.add("JobRunning");
			statusDirectory.add("JobOut");
			statusDirectory.add("archive");
			statusDirectory.add("Suspend");
			statusDirectory.add("JobFailed");
		}
	  
		ArrayList<JobItem> items = new ArrayList<JobItem>();
		ArrayList<JobItem> fileItems = new ArrayList<JobItem>();
		//System.out.println("Dir: " + aFile.getPath());
	  	  
		if(aFile.isDirectory()) 
		{
			/*System.out.println("Parent DIR: " + aFile.getName());
			System.out.println("Username not empty: " + userName);*/
			int count = statusDirectory.size();
			if(userName.length() > 0)
			{
				String userDirectoryPath = aFile.getPath() + File.separator + userName;
				File userDirectory = new File(userDirectoryPath);
				
				for(int i = 0; i < count; i++)
				{
					String statusDirectoryKey = statusDirectory.get(i);
					fileItems = getProjects(userDirectory, statusDirectoryKey, projectName, fileItems, tab);
				}				
			}
			else
			{
				File[] usersDirList = aFile.listFiles();
				/*System.out.println("NUMBER OF Users DIR: " + usersDirList.length);*/
				if(usersDirList != null) 
				{
					for (int i = 0; i < usersDirList.length; i++)
					{
						File userDirectory  = usersDirList[i];
						for(int k = 0; k < count; k++)
						{
							String statusDirectoryKey = statusDirectory.get(k);
							fileItems = getProjects(userDirectory, statusDirectoryKey, projectName, fileItems, tab);
						}											  
					}
				}
			}
			//items = getJobFiles(fileItems, statusDirectory, start, length, ascend, column);
			items = getJobFiles(fileItems, start, length, ascend, column);
		}	  
		return items;
	}
	
	public ArrayList<JobItem> getProjects(File userDirectory, String statusDirectoryKey, String projectName, ArrayList<JobItem> fileItems, int tab)
	{
		ResourceBundle constants = ResourceBundle.getBundle("Paths");
		String projects = constants.getString("projects");
		System.out.println("statusDirectoryKey: " + statusDirectoryKey);
		String statusDirectory = constants.getString(statusDirectoryKey);
		
		if(userDirectory != null)
		{
			//System.out.println("User DIR: " + userDirectory);
			if(userDirectory.isDirectory())
			{
				String user = userDirectory.getName();
				String projectsPath = userDirectory.getPath() + File.separator + projects;
				if(projectName.length() > 0)
				{
					projectsPath = projectsPath + File.separator + projectName;
					File projectDirectory = new File(projectsPath);
					fileItems = getProjectJobFiles(projectDirectory, statusDirectory, fileItems, user, tab);
				}
				else
				{
					File projectDirectories = new File(projectsPath);
					/*System.out.println("PROJECT ROOT DIR: " + projectDirectories);*/
					File[] projectDirectoryList = projectDirectories.listFiles();
					if(projectDirectoryList != null)
					{
						for(int k = 0; k < projectDirectoryList.length; k++)
						{
							File projectDirectory = projectDirectoryList[k];
							/*System.out.println("PROJECT DIR: " + projectDirectory.getPath());*/
							fileItems = getProjectJobFiles(projectDirectory, statusDirectory, fileItems, user, tab);
						}
					}
				}				
			}			
		}
		return fileItems;
	}
	
	public ArrayList<JobItem> getProjectJobFiles(File projectDirectory, String statusDirectory, ArrayList<JobItem> fileItems, String user, int tab)
	{
		if(projectDirectory != null)
		{
			if(projectDirectory.isDirectory())
			{
				System.out.println("~~~~~~~~To get files from: " + projectDirectory.getPath());
				String project = projectDirectory.getName();
				String jobDirectoryPath = projectDirectory.getPath() + File.separator + statusDirectory;
				File jobDirectory = new File(jobDirectoryPath);
				/*System.out.println("JOBS SUB DIR: " + jobDirectory.getPath());*/
				if(jobDirectory != null)
				{
					if(jobDirectory.isDirectory())
					{
						File[] jobFiles = jobDirectory.listFiles();
						
						if(jobFiles != null)
						{
							int count = jobFiles.length;
							
							for (int i = 0; i < count; i++)
							{
								File jobFile  = jobFiles[i];
								if(jobFile.isFile())
								{
									String fileName  = jobFile.getName();
									System.out.println("File: " + jobFile.getPath());
									if(fileName.endsWith(".mat"))
									{				
										JobItem item = new JobItem();
										//item.setJobId(jobId);
										item.setJobName(fileName);
										item.setLastModified(jobFile.lastModified());
										String status = "";
										if(statusDirectory.equals("JobIn"))
										{
											status = "Queued";
										}
										else if(statusDirectory.equals("JobRunning"))
										{
											if(tab == 2)
											{
												status = "Running";
											}
											else
											{
												status = getJobData(jobFile.getPath());
											}																						
										}
										else if(statusDirectory.equals("JobOut") || statusDirectory.equals("Archive"))
										{
											status = "Done";
										}
										else if(statusDirectory.equals("Suspended"))
										{
											status = "Suspended";
										}
										else if(statusDirectory.equals("JobFailed"))
										{
											status = "Failed";
										}
										item.setUsername(user);
										item.setProjectName(project);
										item.setStatus(status);
										fileItems.add(item);							
									}
								}
							}
						}
					}
					else
					{
						System.out.println(" [PROJECT JOB DIRECTORIES ARE NOT CREATED]");
					}
				}				
			}
		}
		return fileItems;
	}
	
	//public ArrayList<JobItem> getJobFiles(ArrayList<JobItem> fileItems, String statusDirectory, int start, int length, boolean ascend, String column)
	public ArrayList<JobItem> getJobFiles(ArrayList<JobItem> fileItems, int start, int length, boolean ascend, String column)
	{
		ArrayList<JobItem> items = new ArrayList<JobItem>();
		fileItems = sort(fileItems, ascend, column);
		totalJobs = fileItems.size();
		System.out.println("Job Count: " + totalJobs);
		
		int end = 0;
		int count  = fileItems.size();
		if(length < count)
		{
			end = length;
		}
		else
		{
			end = count;
		}
		
		for (int i = start; i < end; i++)
		{
			JobItem item = fileItems.get(i);
			items.add(item);			
		}
		return items;
	}
	
	public String getJobData(String filePath)
	{				
		MatFileReader matfilereader=null;
		String status = "Running";
		try
		{
			matfilereader = new MatFileReader(filePath);
			MLStructure mlStructure = (MLStructure) matfilereader.getMLArray("JobInfo");				
			MLChar jobStatus = (MLChar) mlStructure.getField("Status");
			String statusStr = jobStatus.contentToString();
			String tokens[] = statusStr.split("'");
			status = tokens[1].trim();
			
			double statusValue = 0;
			try
			{
				statusValue = Double.parseDouble(status);
			}
			catch(NumberFormatException e)
			{
				e.printStackTrace();
			}
			if(statusValue > 0)
			{
				status = status + "% Complete";
			}
			
			/*if(!status.equalsIgnoreCase("Done") || (!status.equalsIgnoreCase("Running")))
			{
				status = status + "% Complete";
			}*/
		}
		catch (Exception e)
		{
			System.out.println("error reading file");
			e.printStackTrace();
		}		
		System.out.println("Filepath: " + filePath + " Status: " + status);
		return status;		
	}
}