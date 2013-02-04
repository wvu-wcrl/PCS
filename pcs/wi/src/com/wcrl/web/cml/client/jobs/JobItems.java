/*
 * File: JobItems.java

Purpose: A container class to store a collection of Job items.
**********************************************************/

package com.wcrl.web.cml.client.jobs;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class JobItems implements Serializable
{	
	private static final long serialVersionUID = 1L;
	private ArrayList<JobItem> items;
	private static Map<Integer, String> statusMap = new HashMap<Integer, String>();
	
	public JobItems()
	{
		items = new ArrayList<JobItem>();
		//This map is not used in this application. Instead the String - Numeric map provided in JobItem is used
		statusMap.put(0, "New Job");
	    statusMap.put(1, "Not a valid Job file");
	    statusMap.put(2, "Suspended");
	    statusMap.put(3, "Done");
	    //statusMap.put(4, "Done");
	    statusMap.put(5, "Running");
	    statusMap.put(6, "Queued");
	}
	
	public int getJobItemCount() {
	    return items.size();
	}
	
	 public ArrayList<JobItem> getItems() {
		return items;
	}	 

	public void setItems(ArrayList<JobItem> items) {
		this.items = items;
	}	

	public JobItem getJobItem(int index) 
	{
		if (index >= items.size())
		{
			return null;
		}
		return items.get(index);
	}
	
	public JobItem getJobItembyJobID(int jobId) 
	{
		Iterator<JobItem> itr = items.iterator();
		while(itr.hasNext())
		{
			JobItem item = (JobItem) itr.next();
			if(item.getJobId() == jobId)
			{
				return item;
			}
		}
		return null;		
	}

	public void addJobItem(JobItem jobItem)
	{
		items.add(jobItem);
	}
	
	//Update a Job in the Job list
	public void updateJobItem(JobItem jobItem)
	{
		for(int i = 0; i < items.size(); i++)
		{
			JobItem item = items.get(i);
			if(item.getJobId() == jobItem.getJobId())
			{								
				items.set(i, jobItem);				
				break;
			}
		}			
	}
	
	public void deleteJobItem(int jobId)
	{
		for(int i = 0; i < items.size(); i++)
		{
			JobItem item = items.get(i);
			if(item.getJobId() == jobId)
			{
				items.remove(item);
				break;
			}
		}				
	}
	 
	public void removeJobItem(int index)
	{
		items.remove(index);
	}

	public static Map<Integer, String> getStatusMap() {
		return statusMap;
	}

	public static void setStatusMap(Map<Integer, String> statusMap) {
		JobItems.statusMap = statusMap;
	} 
}
