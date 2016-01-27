package com.wcrl.web.cml.server;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.ResourceBundle;

import com.wcrl.web.cml.client.datafiles.DataFileItem;

public class DataFilesList 
{		
	private int totalFiles;
	
	public int getTotalFiles() {
		return totalFiles;
	}

	public void setTotalFiles(int totalFiles) {
		this.totalFiles = totalFiles;
	}

	public ArrayList<DataFileItem> sort(ArrayList<DataFileItem> fileItems, final boolean ascend, String column)
	{		
		//Sort files by Filename
		if(column.equalsIgnoreCase("Name"))
		{
			System.out.println("Column to sort: " + column);
			Collections.sort(fileItems, new Comparator<DataFileItem>() 
			{
				public int compare(DataFileItem o1, DataFileItem o2)
				{
					String a = o1.getFileName();
					String b = o2.getFileName();
					
					return a.compareTo(b);					
				}
			});
		}
		else if(column.equalsIgnoreCase("Date"))
		{
			System.out.println("Column to sort: " + column);
			Collections.sort(fileItems, new Comparator<DataFileItem>() 
			{
				public int compare(DataFileItem o1, DataFileItem o2)
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
				}
			});
		}
		return fileItems;
	}
	
	public ArrayList<DataFileItem> filesList(File aFile, int start, int length, boolean ascend, String column, String userName, String projectName, int tab, String dataDir)
	{  
		ArrayList<DataFileItem> items = new ArrayList<DataFileItem>();
		ArrayList<DataFileItem> fileItems = new ArrayList<DataFileItem>();
	  	  
		if(aFile.isDirectory()) 
		{
			/*System.out.println("Parent DIR: " + aFile.getName());
			System.out.println("Username not empty: " + userName);*/
			if(userName.length() > 0)
			{
				String userDirectoryPath = aFile.getPath() + File.separator + userName;
				File userDirectory = new File(userDirectoryPath);
				fileItems = getProjects(userDirectory, dataDir, projectName, fileItems, tab);
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
						fileItems = getProjects(userDirectory, dataDir, projectName, fileItems, tab);					  
					}
				}
			}
			items = getJobFiles(fileItems, dataDir, start, length, ascend, column);
		}	  
		return items;
	}
	
	public ArrayList<DataFileItem> getProjects(File userDirectory, String dataDir, String projectName, ArrayList<DataFileItem> fileItems, int tab)
	{
		ResourceBundle constants = ResourceBundle.getBundle("Paths");
		String projects = constants.getString("projects");
		
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
					fileItems = getProjectJobFiles(projectDirectory, dataDir, fileItems, user, tab);
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
							fileItems = getProjectJobFiles(projectDirectory, dataDir, fileItems, user, tab);
						}
					}
				}				
			}			
		}
		return fileItems;
	}
	
	public ArrayList<DataFileItem> getProjectJobFiles(File projectDirectory, String dataDir, ArrayList<DataFileItem> fileItems, String user, int tab)
	{
		if(projectDirectory != null)
		{
			if(projectDirectory.isDirectory())
			{
				System.out.println("~~~~~~~~To get files from: " + projectDirectory.getPath());
				String project = projectDirectory.getName();
				String jobDirectoryPath = projectDirectory.getPath() + File.separator + dataDir;
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
									DataFileItem item = new DataFileItem();
									item.setFileName(fileName);
									item.setLastModified(jobFile.lastModified());										
									item.setUsername(user);
									item.setProjectName(project);
									fileItems.add(item);	
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
	
	public ArrayList<DataFileItem> getJobFiles(ArrayList<DataFileItem> fileItems, String dataDir, int start, int length, boolean ascend, String column)
	{
		ArrayList<DataFileItem> items = new ArrayList<DataFileItem>();
		fileItems = sort(fileItems, ascend, column);
		totalFiles = fileItems.size();
		System.out.println("Job Count: " + totalFiles);
		
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
			DataFileItem item = fileItems.get(i);
			items.add(item);			
		}
		return items;
	}	
}