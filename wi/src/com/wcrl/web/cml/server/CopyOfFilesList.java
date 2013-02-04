package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.ResourceBundle;

import com.wcrl.web.cml.client.jobs.JobItem;

public class CopyOfFilesList 
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
	
	public File[] sort(File[] jobFiles, final boolean ascend, String column)
	{		
		//Sort the files by Filename
		if(column.equalsIgnoreCase("Name"))
		{
			System.out.println("Column: " + column);
			Arrays.sort(jobFiles, new Comparator<File>() 
			{
				public int compare(File o1, File o2)
				{
					String a = o1.getName();
					String b = o2.getName();
					if(ascend)
					{
						return a.compareTo(b);
					}
					else
					{
						return b.compareTo(a);
					}
				}
			});
		}
		else if(column.equalsIgnoreCase("Update"))
		{
			System.out.println("DateColumn: " + column);
			Arrays.sort(jobFiles, new Comparator<File>()
			{
				public int compare(File o1, File o2)
				{
					Long a = Long.valueOf(o1.lastModified());
					Long b = Long.valueOf(o2.lastModified());
					if(ascend)
					{
						return a.compareTo(b);
					}
					else
					{
						return b.compareTo(a);
					}
				}
			});
		}
		return jobFiles;
	}
	
  public ArrayList<JobItem> filesList(File aFile, String status, int start, int length, boolean ascend, String column, String userName, String projectName)
  {
	  ResourceBundle constants = ResourceBundle.getBundle("Paths");
	  String projects = constants.getString("projects");
	  
	  String statusDirectory = "";
	  if(status.equals("Queued"))
	  {
		  statusDirectory = "JobIn";
	  }
	  else if(status.equals("Running"))
	  {
		  statusDirectory = "JobRunning";
	  }
	  else if(status.equals("Done"))
	  {
		  statusDirectory = "JobOut";
	  }
	  else if(status.equals("Archive"))
	  {
		  statusDirectory = "archive";
	  }
	  
	  ArrayList<JobItem> items = new ArrayList<JobItem>();
	  System.out.println("Dir: " + aFile.getPath());
	  	  
	  if (aFile.isDirectory()) 
	  {
		  System.out.println("Parent DIR: " + aFile.getName());
		  File[] projectDirList = aFile.listFiles();
		  System.out.println("NUMBER OF Users DIR: " + projectDirList.length);
		  if(projectDirList != null) 
		  {
			  for (int i = 0; i < projectDirList.length; i++)
			  {
				  File directory  = projectDirList[i];				  
				  if(directory != null)
				  {
					  System.out.println("User DIR: " + directory);
					  if(directory.isDirectory())
					  {
						  String projectsPath = directory.getPath() + File.separator + projects;
						  File projectDirectories = new File(projectsPath);
						  System.out.println("SUB SUB DIR: " + projectDirectories);
						  File[] projectDirectoryList = projectDirectories.listFiles();
						  if(projectDirectoryList != null)
						  {
							  for(int k = 0; k < projectDirectoryList.length; k++)
							  {
								  File projectDirectoryPath = projectDirectoryList[k];	
								  System.out.println("PROJECT ROOT DIR: " + projectDirectoryPath.getPath());
								  if(projectDirectoryPath.isDirectory())
								  {
									  String jobDirectoryPath = projectDirectoryPath.getPath() + File.separator + statusDirectory;
									  File jobDirectory = new File(jobDirectoryPath);
									  System.out.println("JOBS SUB DIR: " + jobDirectory.getPath());
									  
									  File[] jobFiles = jobDirectory.listFiles();
									  if(jobFiles != null)
									  {										  									  
										  //New
										  jobFiles = sort(jobFiles, ascend, column);	
										  totalJobs = jobFiles.length;
										  System.out.println("Job Count: " + totalJobs);
										  int end = 0;
										  int count  = jobFiles.length;
										  if(length < count)
										  {
											  end = length;
										  }
										  else
										  {
											  end = count;
										  }
										  
										  for (int j = start; j < end; j++)
										  {
											  File jobFile  = jobFiles[j];
											  if(jobFile.isFile())
											  {
												  String fileName  = jobFile.getName();
												  if(fileName.endsWith(".mat"))
												  {
													  JobItem item = new JobItem();
													  //item.setJobId(jobId);
													  item.setJobName(fileName);
													  item.setLastModified(jobFile.lastModified());
													  //String status = "";
													  if(jobDirectory.equals("JobIn"))
													  {
														  status = "Queued";
													  }
													  else if(jobDirectory.equals("JobRunning"))
													  {
														  status = "Running";
													  }
													  else if(jobDirectory.equals("JobOut") || jobDirectory.equals("archive"))
													  {
														  status = "Done";
													  }
													  item.setStatus(status);
													  items.add(item);												  
													  //System.out.println("[DIRECTORY] " + subDirectoryPath.getName() + " [FILE] " + fileName);												 
												  }
											  }
										   }
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
	  }	  
	return items;
  }
}
