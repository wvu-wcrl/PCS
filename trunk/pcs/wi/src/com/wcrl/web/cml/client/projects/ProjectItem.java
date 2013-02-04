/*
 * File: JobItem.java

Purpose: Java bean class to store the attributes of a Job.
**********************************************************/

package com.wcrl.web.cml.client.projects;

import java.io.Serializable;

public class ProjectItem implements Serializable 
{	
	private static final long serialVersionUID = -3996651421304266493L;
	private int projectId;
	private String projectName;
	private String description;	
	private String path;
	private String dataFile;
	private long lastUpdate;
	  
	public ProjectItem()
	{
		
	}

	public ProjectItem(int projectId, String projectName)
	{
		this.projectId = projectId;
		this.projectName = projectName;		
	}

	public int getProjectId() {
		return projectId;
	}

	public void setProjectId(int projectId) {
		this.projectId = projectId;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public String getDataFile() {
		return dataFile;
	}

	public void setDataFile(String dataFile) {
		this.dataFile = dataFile;
	}

	public long getLastUpdate() {
		return lastUpdate;
	}

	public void setLastUpdate(long lastUpdate) {
		this.lastUpdate = lastUpdate;
	}

}
