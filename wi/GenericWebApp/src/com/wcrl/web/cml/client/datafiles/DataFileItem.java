/*
 * File: JobItem.java

Purpose: Java bean class to store the attributes of a Job.
**********************************************************/

package com.wcrl.web.cml.client.datafiles;

import java.io.Serializable;

public class DataFileItem implements Serializable 
{	
	private static final long serialVersionUID = -3996651421304266493L;
	private int userId;
	private String username;
	private int fileId;
	private String fileName;
	private String fileDescription;	
	private long lastModified;	
    private String fileNotes;    
    private int projectId;
    private String projectName;
    private String path;
    
	public DataFileItem()
	{
		
	}

	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public int getFileId() {
		return fileId;
	}

	public void setFileId(int fileId) {
		this.fileId = fileId;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFileDescription() {
		return fileDescription;
	}

	public void setFileDescription(String fileDescription) {
		this.fileDescription = fileDescription;
	}

	public String getFileNotes() {
		return fileNotes;
	}

	public void setFileNotes(String fileNotes) {
		this.fileNotes = fileNotes;
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

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public long getLastModified() {
		return lastModified;
	}

	public void setLastModified(long lastModified) {
		this.lastModified = lastModified;
	}
}