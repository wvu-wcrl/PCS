/*
 * File: JobItems.java

Purpose: A container class to store a collection of Job items.
**********************************************************/

package com.wcrl.web.cml.client.projects;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;

public class ProjectItems implements Serializable
{	
	private static final long serialVersionUID = 1L;
	private ArrayList<ProjectItem> items;
		
	public ProjectItems()
	{
		items = new ArrayList<ProjectItem>();
	}
	
	public int getProjectItemCount() {
	    return items.size();
	}
	
	 public ArrayList<ProjectItem> getItems() {
		return items;
	}	 

	public void setItems(ArrayList<ProjectItem> items) {
		this.items = items;
	}	

	public ProjectItem getProjectItem(int index) 
	{
		if (index >= items.size())
		{
			return null;
		}
		return items.get(index);
	}
	
	public ProjectItem getProjectItembyID(int projectId) 
	{
		Iterator<ProjectItem> itr = items.iterator();
		while(itr.hasNext())
		{
			ProjectItem item = (ProjectItem) itr.next();
			if(item.getProjectId() == projectId)
			{
				return item;
			}
		}
		return null;		
	}

	public void addProjectItem(ProjectItem projectItem)
	{
		items.add(projectItem);
	}
	
	//Update a Project in the Project list
	public void updateJobItem(ProjectItem projectItem)
	{
		for(int i = 0; i < items.size(); i++)
		{
			ProjectItem item = items.get(i);
			if(item.getProjectId() == projectItem.getProjectId())
			{								
				items.set(i, projectItem);				
				break;
			}
		}			
	}
	
	public void deleteProjectItem(int jobId)
	{
		for(int i = 0; i < items.size(); i++)
		{
			ProjectItem item = items.get(i);
			if(item.getProjectId() == jobId)
			{
				items.remove(item);
				break;
			}
		}				
	}
	 
	public void removeProjectItem(int index)
	{
		items.remove(index);
	}
}
