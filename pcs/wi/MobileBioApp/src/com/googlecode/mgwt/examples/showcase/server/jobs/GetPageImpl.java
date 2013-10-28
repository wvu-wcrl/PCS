/*
 * File: UploadedJobListServiceImpl.java

Purpose: Java handler class to get a list of jobs of an user.
**********************************************************/
package com.googlecode.mgwt.examples.showcase.server.jobs;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ResourceBundle;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.JobItem;
import com.googlecode.mgwt.examples.showcase.client.custom.jobs.service.GetPageService;

public class GetPageImpl extends RemoteServiceServlet implements GetPageService 
{	
	private static final long serialVersionUID = 1L;
	private int totalJobs = 0;
	
	public List<JobItem> getPage(int start, int length, boolean ascend, String statusDirectory, String user, String project, int tab)
	{
		ResourceBundle constants = ResourceBundle.getBundle("Paths");
		String dirPath = constants.getString("path"); 
		File aFile = new File(dirPath);
		FilesList files = new FilesList();
		ArrayList<JobItem> jobItems = files.filesList(aFile, statusDirectory, start, length, ascend, "Date", user, project, tab);
		this.totalJobs = files.getTotalJobs();
		System.out.println("GetPage start: " + start + " length: " + length);
		System.out.println("Dir path: " + dirPath + " Dir: " + aFile.getPath() + " " + aFile.getAbsolutePath());
	
		System.out.println("GetPage ItemCount: " + jobItems.size());
		return jobItems;	
	}	
	public int getJobNumber()
	{		
		//return files.getTotalJobs();
		return this.totalJobs;
	}
	
	public void sort(ArrayList<JobItem> jobItems, final boolean ascend)
	{		
		//Sort the files by Filename
	    Collections.sort(jobItems, new Comparator<JobItem>() 
	    {
	          public int compare(JobItem o1, JobItem o2) 
	          {	        	 
	        	  String a = o1.getJobName();
	        	  String b = o2.getJobName();
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
}
