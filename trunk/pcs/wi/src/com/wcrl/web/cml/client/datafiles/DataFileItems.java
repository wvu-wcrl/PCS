/*
 * File: JobItems.java

Purpose: A container class to store a collection of Job items.
**********************************************************/

package com.wcrl.web.cml.client.datafiles;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;

public class DataFileItems implements Serializable
{	
	private static final long serialVersionUID = 1L;
	private ArrayList<DataFileItem> items;
	
	public DataFileItems()
	{
		items = new ArrayList<DataFileItem>();
	}
	
	public int getFileItemCount() {
	    return items.size();
	}
	
	 public ArrayList<DataFileItem> getItems() {
		return items;
	}	 

	public void setItems(ArrayList<DataFileItem> items) {
		this.items = items;
	}	

	public DataFileItem getDataFileItem(int index) 
	{
		if (index >= items.size())
		{
			return null;
		}
		return items.get(index);
	}
	
	public DataFileItem getDataFileItembyID(int jobId) 
	{
		Iterator<DataFileItem> itr = items.iterator();
		while(itr.hasNext())
		{
			DataFileItem item = (DataFileItem) itr.next();
			if(item.getFileId() == jobId)
			{
				return item;
			}
		}
		return null;		
	}

	public void addDataFileItem(DataFileItem item)
	{
		items.add(item);
	}
	
	//Update a Job in the Job list
	public void updateDataFileItem(DataFileItem fileItem)
	{
		for(int i = 0; i < items.size(); i++)
		{
			DataFileItem item = items.get(i);
			if(item.getFileId() == fileItem.getFileId())
			{								
				items.set(i, fileItem);				
				break;
			}
		}			
	}
	
	public void deleteFileItem(int fileId)
	{
		for(int i = 0; i < items.size(); i++)
		{
			DataFileItem item = items.get(i);
			if(item.getFileId() == fileId)
			{
				items.remove(item);
				break;
			}
		}				
	}
	 
	public void removeDataFileItem(int index)
	{
		items.remove(index);
	}
}
